#!/usr/bin/env python3
"""Sync release assets to Telegram and keep releases.json up to date.

Discovery comes from the GitHub release API on every run, so assets added
upstream are picked up automatically and assets removed upstream are marked
"removed". releases.json is only the memory of what was already announced.

Env vars:
  TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID   required (unless DRY_RUN)
  TELEGRAM_TOPIC_ID                      optional forum topic
  GH_TOKEN                               optional, raises GitHub API limits
  SOURCE_REPO, SOURCE_TAG                release to watch
  DB_FILE                                default: releases.json
  DRY_RUN=true                           print messages, write nothing
  NOTIFY_REMOVED=true                    also post a message when an asset disappears

Unknown apps and mods are learned automatically (appended to catalog.json): apps from the
APK, mods from the last word of the filename. Rename an entry in catalog.json if a guess is ugly.
"""
import contextlib
import hashlib
import html
import io
import json
import logging
import os
import re
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

import requests
from pyaxmlparser import APK

ROOT = Path(__file__).resolve().parent
CATALOG = json.loads((ROOT / "catalog.json").read_text(encoding="utf-8"))

REPO = os.getenv("SOURCE_REPO", "FiorenMas/Revanced-And-Revanced-Extended-Non-Root")
TAG = os.getenv("SOURCE_TAG", "all")
DB_FILE = Path(os.getenv("DB_FILE", "releases.json"))


def flag(name):
    return os.getenv(name, "").strip().lower() in ("1", "true", "yes")


DRY_RUN = flag("DRY_RUN")
NOTIFY_REMOVED = flag("NOTIFY_REMOVED")

BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN", "").strip()
CHAT_ID = os.getenv("TELEGRAM_CHAT_ID", "").strip()
TOPIC_ID = os.getenv("TELEGRAM_TOPIC_ID", "").strip()
GH_TOKEN = os.getenv("GH_TOKEN", "").strip()

GH_HEADERS = {"Accept": "application/vnd.github.v3+json"}
if GH_TOKEN:
    GH_HEADERS["Authorization"] = f"Bearer {GH_TOKEN}"

PACKAGE_BY_APP = {a["name"]: a.get("package") for a in CATALOG["apps"]}
ARCHES = [
    ("arm64-v8a", "Arm64-v8a"),
    ("armeabi-v7a", "Armeabi-v7a"),
    ("x86_64", "x86_64"),
    ("x86", "x86"),
]


def progress(idx, total):
    filled = 20 * idx // total
    bar = "█" * filled + "░" * (20 - filled)
    return f"[{idx:>{len(str(total))}}/{total}] ({idx / total * 100:5.1f}%) |{bar}|"


def now_iso():
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


# ---------------------------------------------------------------------------
# Filename / README parsing
# ---------------------------------------------------------------------------
def first_match(text, table):
    """First catalog entry (in catalog order) with any `match` key inside text."""
    for entry in table:
        if any(key in text for key in entry["match"]):
            return entry
    return None


def strip_arch(clean):
    for key, _ in ARCHES:
        clean = clean.replace(key, "")
    return re.sub(r"-{2,}", "-", clean).strip("-")


def app_key(clean, label=""):
    """Leading part of a filename that names the app: 'mystery-app-piko-v1.2.3' -> 'mystery-app'.

    The APK label (e.g. "Mystery App") tells us where the app name ends and an unknown mod begins.
    """
    mod_keys = [k for m in CATALOG["mods"] for k in m["match"]]
    words = set(re.findall(r"[a-z0-9]+", label.lower()))
    tokens, parts = strip_arch(clean).split("-"), []
    for i, tok in enumerate(tokens):
        rest = "-".join(tokens[i:])
        if (
            re.match(r"v?\d", tok)
            or any(rest.startswith(k) for k in mod_keys)
            or (words and parts and tok not in words)
        ):
            break
        parts.append(tok)
    key = "-".join(parts)
    return key if len(key) >= 3 else ""


def parse_filename(filename, label=""):
    clean = filename.lower().removesuffix(".apk")

    arch = next((label for key, label in ARCHES if key in clean), "All Architectures")

    app_entry = first_match(clean, CATALOG["apps"])
    app = app_entry["name"] if app_entry else None

    # Best-effort guess, only used if neither catalog, README nor the APK label know the app
    g = re.match(r"(?:gg-|google[-_]?)([a-z0-9]+)", clean)
    guess = f"Google {g.group(1).capitalize()}" if g else clean.split("-")[0].capitalize()

    mod_entry = first_match(clean, CATALOG["mods"])
    if mod_entry:
        mod = mod_entry["name"]
    else:
        parts = [p for p in strip_arch(clean).split("-") if not re.match(r"v?\d", p)]
        app_tokens = set(re.split(r"[-_]", "-".join(app_entry["match"]))) if app_entry else set(app_key(clean, label).split("-"))
        mod = "General"
        if len(parts) > 1 and parts[-1] not in app_tokens:
            mod = parts[-1].capitalize()  # last token that isn't part of the app name
            if mod.lower() in NOT_A_MOD:  # e.g. "stable", "beta": not who made the patch
                mod = "General"

    v = re.search(r"v?(\d+\.\d+(?:\.\d+)?)", filename)
    return {
        "app": app,
        "key": app_key(clean, label),
        "guess": guess,
        "mod": mod,
        "mod_known": bool(mod_entry),
        "arch": arch,
        "version": v.group(1) if v else "",
        "beta": "beta" in clean,
    }


def readme_hints():
    """filename -> (app, mod), taken from the section headings of the upstream README."""
    hints = {}
    try:
        res = requests.get(
            f"https://api.github.com/repos/{REPO}/contents/README.md",
            headers={**GH_HEADERS, "Accept": "application/vnd.github.v3.raw"},
            timeout=30,
        )
        res.raise_for_status()
    except requests.RequestException as exc:
        print(f"README not available ({exc}); using filename parsing only.")
        return hints

    app = mod = ""
    for line in res.text.splitlines():
        plain = re.sub(r"<[^>]+>", "", line).strip()
        if plain.endswith(":") and len(plain) < 45:
            cand = plain.rstrip(":").strip().lower()
            for entry in CATALOG["apps"]:
                if cand == entry["name"].lower():
                    app, mod = entry["name"], ""
                    break
            for entry in CATALOG["mods"]:
                if entry["name"].lower() in cand:
                    mod = entry["name"]
                    break
        for fname in re.findall(r"/releases/download/all/([\w.\-]+\.apk)", line):
            hints[fname] = (app, mod)
    print(f"README gave hints for {len(hints)} files.")
    return hints


# ---------------------------------------------------------------------------
# APK metadata
# ---------------------------------------------------------------------------
@contextlib.contextmanager
def quiet():
    """Mute everything the APK parser prints or logs.

    pyaxmlparser is chatty on patched APKs ("res0 is not zero!", "RES_TABLE_LIBRARY_TYPE chunk
    is not supported", "invalid decoded string length", ...). Besides Python-level logging and
    print, the real stdout/stderr file descriptors are pointed at /dev/null for the duration,
    so even handlers bound to the original streams stay quiet.
    """
    sys.stdout.flush()
    sys.stderr.flush()
    saved, devnull = [], None
    try:
        saved = [os.dup(1), os.dup(2)]
        devnull = os.open(os.devnull, os.O_WRONLY)
        os.dup2(devnull, 1)
        os.dup2(devnull, 2)
    except OSError:
        pass  # no usable fds (unusual): the Python-level muting below still applies
    logging.disable(logging.CRITICAL)
    try:
        with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
            yield
    finally:
        logging.disable(logging.NOTSET)
        if len(saved) == 2:
            os.dup2(saved[0], 1)
            os.dup2(saved[1], 2)
        for fd in (*saved, devnull):
            if fd is not None:
                os.close(fd)


def apk_metadata(path):
    meta = {}
    try:
        with quiet():
            apk = APK(str(path))
            package, version = apk.package, apk.version_name
            label = getattr(apk, "application", None)
        if package:
            meta["package"] = package
        if version:
            meta["version"] = str(version).strip()
        if label:
            meta["label"] = str(label).strip()
    except Exception:
        pass

    if not meta.get("package") or not meta.get("version"):
        try:
            out = subprocess.check_output(
                ["aapt", "dump", "badging", str(path)], stderr=subprocess.DEVNULL, text=True
            )
            pkg = re.search(r"package:\s+name='([^']+)'", out)
            ver = re.search(r"versionName='([^']+)'", out)
            if pkg:
                meta.setdefault("package", pkg.group(1))
            if ver:
                meta.setdefault("version", ver.group(1))
        except Exception:
            pass
    return meta


# ---------------------------------------------------------------------------
# GitHub release assets
# ---------------------------------------------------------------------------
def fetch_assets():
    base = f"https://api.github.com/repos/{REPO}/releases"
    res = requests.get(f"{base}/tags/{TAG}", headers=GH_HEADERS, timeout=30)
    res.raise_for_status()
    release_id = res.json()["id"]

    assets, page = [], 1
    while True:
        res = requests.get(
            f"{base}/{release_id}/assets?per_page=100&page={page}", headers=GH_HEADERS, timeout=30
        )
        res.raise_for_status()  # a partial list must never look like "assets were removed"
        batch = res.json()
        assets.extend(batch)
        if len(batch) < 100:
            return assets
        page += 1


def api_sha256(asset):
    """SHA-256 reported by the GitHub API (the `digest` field), if present."""
    digest = asset.get("digest") or ""
    return digest.split(":", 1)[1].lower() if digest.startswith("sha256:") else None


def download(asset):
    path = Path(asset["name"])
    sha = hashlib.sha256()
    with requests.get(asset["browser_download_url"], stream=True, timeout=120) as r:
        r.raise_for_status()
        with path.open("wb") as f:
            for chunk in r.iter_content(chunk_size=1 << 16):
                f.write(chunk)
                sha.update(chunk)
    return path, sha.hexdigest()


# ---------------------------------------------------------------------------
# releases.json
# ---------------------------------------------------------------------------
def load_db():
    if DB_FILE.exists():
        return json.loads(DB_FILE.read_text(encoding="utf-8"))
    return {}


def save_db(db):
    if DRY_RUN:
        return
    DB_FILE.write_text(
        json.dumps(db, indent=2, sort_keys=True, ensure_ascii=False) + "\n", encoding="utf-8"
    )


def learn_app(parsed, meta, app_hint):
    """Teach the catalog an app it doesn't know yet. Returns True if catalog.json changed."""
    key, pkg = parsed["key"], meta.get("package")
    if parsed["app"] or app_hint or not key or not pkg:
        return False
    entry = next((a for a in CATALOG["apps"] if a.get("package") == pkg), None)
    if entry:  # known app, just a new filename spelling
        entry["match"].append(key)
    else:
        entry = {"name": meta.get("label") or parsed["guess"], "package": pkg, "match": [key]}
        CATALOG["apps"].append(entry)
    PACKAGE_BY_APP[entry["name"]] = pkg
    print(f"Learned app '{entry['name']}' ({pkg}) from filename key '{key}'")
    return True


NOT_A_MOD = {
    "stable", "beta", "latest", "release", "android", "universal", "all", "arm", "arm64",
    "armv7", "apk", "patched", "mod", "modded", "signed", "final", "extended", "lite",
}


def learn_mod(parsed, mod_hint):
    """Add the last filename word as a mod if no known mod matched. Returns True if catalog changed."""
    token = parsed["mod"].lower()
    if parsed["mod_known"] or mod_hint or parsed["mod"] == "General":
        return False
    if not re.fullmatch(r"[a-z][a-z0-9_]{3,}", token) or token in NOT_A_MOD:
        return False
    CATALOG["mods"].append({"name": parsed["mod"], "match": [token]})
    print(f"Learned mod '{parsed['mod']}' from filename word '{token}'")
    return True


def save_catalog():
    if not DRY_RUN:
        (ROOT / "catalog.json").write_text(
            json.dumps(CATALOG, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
        )


def make_record(asset, sha, hints, meta=None, old=None):
    """Build the releases.json entry. Works without the APK (falls back to `old`)."""
    old, meta = old or {}, meta or {}
    name = asset["name"]
    parsed = parse_filename(name, meta.get("label", ""))
    app_hint, mod_hint = hints.get(name, ("", ""))

    app = app_hint or parsed["app"] or meta.get("label") or old.get("app") or parsed["guess"]
    if parsed["beta"] and not app.lower().endswith("beta"):
        app += " Beta"

    package = (
        meta.get("package")
        or old.get("package")
        or PACKAGE_BY_APP.get(app.removesuffix(" Beta").strip())
    )
    changed = old.get("sha256") != sha
    rec = {
        "app": app,
        "package": package,
        "version": meta.get("version") or old.get("version") or parsed["version"] or None,
        "mod": mod_hint or parsed["mod"],
        "variant": parsed["arch"],
        "file": name,
        "size": asset.get("size", 0),
        # date = when this exact content was released; re-uploads of identical bytes don't move it
        "date": asset.get("updated_at") if changed or not old.get("date") else old["date"],
        "sha256": sha,
        "url": asset["browser_download_url"],
        "status": "active",
        "posted": False,
    }
    if not api_sha256(asset):
        # No digest from the API: this stamp lets later runs skip the download if nothing changed
        rec["updated_at"] = asset.get("updated_at")
    return rec


# ---------------------------------------------------------------------------
# Telegram
# ---------------------------------------------------------------------------
def hashtags(rec):
    mod = rec["mod"]
    names = [rec["app"], mod.split("(")[0], *re.findall(r"\((.*?)\)", mod)]
    seen, tags = set(), []
    for n in names:
        clean = re.sub(r"[^a-zA-Z0-9]", "", n)
        if clean and clean.lower() not in seen and clean.lower() != "general":
            seen.add(clean.lower())
            tags.append(f"#{clean}")
    return " ".join(tags)


def fmt_date(iso):
    try:
        return datetime.fromisoformat(iso.replace("Z", "+00:00")).strftime("%d %b %Y, %H:%M UTC")
    except Exception:
        return iso or ""


def row(icon, label, value, code=False):
    if not value:
        return None
    v = html.escape(str(value))
    return f"{icon} <b>{label}:</b> " + (f"<code>{v}</code>" if code else v)


def build_message(rec):
    parts = [
        "🚀 <b>New App Update!</b>",
        "",
        row("📱", "App", rec["app"]),
        row("📦", "Package", rec["package"], code=True),
        row("🔢", "Version", rec["version"], code=True),
        row("🛠", "Mod", rec["mod"]),
        row("🏷", "Variant", rec["variant"]),
        row("📁", "File", rec["file"], code=True),
        row("📊", "Size", f"{rec['size'] / (1024 * 1024):.2f} MB"),
        row("📅", "Date", fmt_date(rec["date"])),
        "",
        f"🔑 <b>SHA-256:</b>\n<code>{rec['sha256']}</code>",
        "",
        f'🔗 <a href="{html.escape(rec["url"], quote=True)}"><b>Direct Download Link</b></a>',
        "",
        hashtags(rec),
    ]
    return "\n".join(p for p in parts if p is not None)


def send_telegram(text):
    if DRY_RUN:
        print("---- DRY RUN message ----\n" + text + "\n-------------------------")
        return True

    url = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"
    payload = {
        "chat_id": CHAT_ID,
        "text": text,
        "parse_mode": "HTML",
        "disable_web_page_preview": True,
    }
    if TOPIC_ID:
        payload["message_thread_id"] = int(TOPIC_ID)

    attempts = 5
    for attempt in range(1, attempts + 1):
        wait = 2 ** (attempt - 1)
        try:
            res = requests.post(url, json=payload, timeout=30)
            if res.status_code == 200:
                return True
            if res.status_code == 429:
                wait = res.json().get("parameters", {}).get("retry_after", 5)
            elif res.status_code < 500:
                print(f"Telegram error {res.status_code}: {res.text}")
                return False
        except requests.RequestException as exc:
            print(f"Telegram request failed: {exc}")
        if attempt < attempts:
            print(f"Retrying in {wait}s (attempt {attempt}/{attempts})...")
            time.sleep(wait)
    return False


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    if not DRY_RUN:
        missing = [n for n, v in (("TELEGRAM_BOT_TOKEN", BOT_TOKEN), ("TELEGRAM_CHAT_ID", CHAT_ID)) if not v]
        if missing:
            sys.exit(
                "ERROR: missing secret(s): " + ", ".join(missing)
                + "\nAdd them in Repository Settings -> Secrets and variables -> Actions"
            )

    db = load_db()
    print(f"Checking {REPO} release '{TAG}'...")
    assets = fetch_assets()
    if not assets:
        sys.exit(f"No assets found in tag '{TAG}'; refusing to touch {DB_FILE}.")
    print(f"{len(assets)} assets in tag '{TAG}', {len(db)} records in {DB_FILE}")
    hints = readme_hints()

    stats = {"announced": 0, "unchanged": 0, "failed": 0, "removed": 0}
    catalog_dirty, warned_mods = False, set()

    for idx, asset in enumerate(assets, 1):
        name = asset["name"]
        old = db.get(name)
        print(f"\n{progress(idx, len(assets))} {name}")

        path = None
        try:
            sha = api_sha256(asset)
            if (
                sha is None and old and old.get("sha256")
                and old.get("updated_at") == asset.get("updated_at")
                and old.get("size") == asset.get("size")
            ):
                sha = old["sha256"]  # no digest from the API, but file looks untouched
            # Only download when we must: new file, changed hash, or no way to tell
            if sha is None or old is None or old.get("sha256") != sha:
                why = "no digest from API" if sha is None else "new file" if old is None else "hash changed"
                print(f"    ⬇ downloading ({why}, {asset.get('size', 0) / (1024 * 1024):.1f} MB)")
                path, sha = download(asset)

            changed = old is None or old.get("sha256") != sha
            meta = apk_metadata(path) if path else {}

            parsed = parse_filename(name, meta.get("label", ""))
            app_hint, mod_hint = hints.get(name, ("", ""))
            if path and learn_app(parsed, meta, app_hint):
                catalog_dirty = True
            if learn_mod(parsed, mod_hint):
                catalog_dirty = True
            elif not parsed["mod_known"] and not mod_hint and parsed["mod"] not in warned_mods:
                warned_mods.add(parsed["mod"])
                print(f"::warning::Couldn't tell the mod for {name} (using '{parsed['mod']}'). "
                      "Add it to scripts/catalog.json if it needs a proper name.")

            rec = make_record(asset, sha, hints, meta, old)
            rec["posted"] = bool(old and old.get("posted")) and not changed

            details = f"{rec['package'] or 'N/A'} | {rec['version'] or 'N/A'} | sha256 {sha[:12]}…"
            if rec["posted"]:
                stats["unchanged"] += 1
                print(f"    ✔ already released | {details}")
            else:
                kind = "new" if old is None else "updated" if changed else "retry"
                print(f"    🚀 announcing ({kind}) | {details}")
                rec["posted"] = send_telegram(build_message(rec))
                if rec["posted"]:
                    stats["announced"] += 1
                    print("    ✔ posted to Telegram")
                    time.sleep(1.2)
                else:
                    stats["failed"] += 1  # stays posted=False, retried next run
                    print("    ✖ Telegram post failed (will retry next run)")
        except Exception as exc:
            print(f"    ✖ failed: {exc}")
            stats["failed"] += 1
            continue
        finally:
            if path:
                path.unlink(missing_ok=True)

        if rec != old:
            db[name] = rec
            save_db(db)

    if catalog_dirty:
        save_catalog()

    # Assets that vanished upstream: keep the record (history + no re-post if they come back)
    current = {a["name"] for a in assets}
    for name, rec in db.items():
        if name not in current and rec.get("status") != "removed":
            rec["status"], rec["removed_at"] = "removed", now_iso()
            stats["removed"] += 1
            print(f"Removed upstream: {name}")
            if NOTIFY_REMOVED:
                send_telegram(
                    f"🗑 <b>Removed:</b> <code>{html.escape(name)}</code>\n"
                    f"{html.escape(rec.get('app') or '')} {html.escape(rec.get('version') or '')}".strip()
                )
    if stats["removed"]:
        save_db(db)

    print("\nDone: " + " | ".join(f"{k}: {v}" for k, v in stats.items()))
    if stats["failed"]:
        sys.exit(1)


if __name__ == "__main__":
    main()
