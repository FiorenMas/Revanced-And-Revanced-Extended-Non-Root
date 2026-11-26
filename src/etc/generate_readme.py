import argparse
from collections import Counter
import hashlib
from html import escape, unescape
import json
import re
from pathlib import Path
from urllib.parse import quote


# Keep these apps at the top of both the index and download catalog.
POPULAR_APPS = ('YouTube', 'YouTube Music', 'Facebook', 'Instagram', 'Threads')

ROOT = Path(__file__).resolve().parents[2]
INDEX = '  <summary><h2>List of available apps</h2></summary>'
MICROG = '## [MicroG RE:]'
LIBRARIES = '### ⚠️ Libraries and resources used in this repository:'
APK_LINK = re.compile(r'\[([^\]\n]+)\]\(\.\./\.\./releases/download/all/([\w.-]+\.apk)[ \t]*\)')
APP_HEADING = re.compile(r'^### \[([^\]]+)\]\([^\n]*\)$', re.MULTILINE)
BADGE = 'https://img.shields.io/badge/Add_to-Obtainium-2D7D46'
REDIRECT = 'https://apps.obtainium.imranr.dev/redirect?r='
GENERATED_BADGE = re.compile(r' *\[!\[Add to Obtainium\]\(' + re.escape(BADGE) + r'\)\]\(' + re.escape(REDIRECT) + r'[^\s)]+\)')


# Remove only known ABI tokens, not provider, release channel or edition names.
ABI = re.compile(r'-(?:arm64-v8a|armeabi-v7a|x86_64|x86)(?=-|\.apk$)')


def asset_family(filename):
    # Upstream lists this double-beta filename alongside the universal beta.
    if filename == 'reddit-beta-arm64-v8a-beta-revanced-extended.apk':
        return 'reddit-beta-revanced-extended.apk'
    return ABI.sub('', filename)


def obtainium_url(repository, filenames):
    url = f'https://github.com/{repository}'
    family = asset_family(filenames[0])
    name = family.removesuffix('.apk')
    # Match only documented assets within this family. Obtainium then filters
    # those candidates using Android's supported ABIs.
    alternatives = '|'.join(re.escape(filename) for filename in sorted(set(filenames)))
    settings = {
        'apkFilterRegEx': '^(?:' + alternatives + ')$',
        'autoApkFilterByArch': True,
        'useLatestAssetDateAsReleaseDate': True,
        'releaseDateAsVersion': True,
        'versionDetection': False,
        'appName': name,
    }
    config = {
        'id': hashlib.sha256(f'{url}/{family}'.encode()).hexdigest()[:12],
        'url': url,
        'author': repository.split('/')[0],
        'name': name,
        'additionalSettings': json.dumps(settings, separators=(',', ':')),
        'overrideSource': 'GitHub',
        'allowIdChange': True,
    }
    payload = quote(json.dumps(config, separators=(',', ':')), safe='')
    return f'{REDIRECT}obtainium://app/{payload}'


# Recognize the maintainer's generated HTML rows as well as original Markdown.
HTML_ROW = re.compile(
    r'  <tr>\n    <td><a href="(\.\./\.\./releases/download/all/[\w.-]+\.apk)[ \t]*">([^<]+)</a></td>\n'
    r'    <td>(?:<a href="' + re.escape(REDIRECT) + r'[^"\n]+"><img src="'
    + re.escape(BADGE) + r'" alt="Add to Obtainium"></a>)?</td>\n  </tr>\n'
)
TABLE = re.compile(r'(?:^\|[^\n]*\n?)+', re.MULTILINE)
HTML_TABLE = re.compile(r'^<table>\n(.*?)^</table>', re.MULTILINE | re.DOTALL)
STANDALONE = re.compile(r'^' + APK_LINK.pattern + r'[ \t]*$', re.MULTILINE)
APK_PATH = '../../releases/download/all/'


def obtainium_badge(repository, filenames):
    return f'[![Add to Obtainium]({BADGE})]({obtainium_url(repository, filenames)})'


def grouped_downloads(links):
    # Keep original row order. Only the first row of each family has a badge.
    groups = {}
    for label, filename in links:
        groups.setdefault(asset_family(filename), []).append(filename)
    seen = set()
    for label, filename in links:
        family = asset_family(filename)
        yield label, filename, groups[family] if family not in seen else []
        seen.add(family)


def render_download_tables(body, repository):
    # Normalize our HTML and Markdown badges before re-rendering. Never remove
    # unrelated HTML or prose, and fail on unrecognized download table rows.
    def restore_html(match):
        rows = list(HTML_ROW.finditer(match.group(1)))
        if not rows or ''.join(row.group(0) for row in rows) != match.group(1):
            if APK_PATH in match.group(0):
                raise ValueError('Unexpected HTML download table')
            return match.group(0)
        return '\n\n'.join(f'[{unescape(row.group(2))}]({row.group(1)})' for row in rows)

    body = HTML_TABLE.sub(restore_html, body)
    body = GENERATED_BADGE.sub('', body)

    def split_cells(line):
        line = line.strip()
        return [cell.strip() for cell in line.removeprefix('|').removesuffix('|').split('|')]

    def render_markdown(match):
        block = match.group(0)
        if not APK_LINK.search(block):
            return block
        header, divider, *rows = map(split_cells, block.splitlines())
        # A trailing empty cell is significant in the new two-column header.
        # Old tables contain either one or two release channels.
        if len(header) not in (1, 2) or len(divider) != len(header):
            raise ValueError('Unexpected download table header: ' + block.splitlines()[0])
        if any(not re.fullmatch(r':?-+:?', cell) for cell in divider):
            raise ValueError('Unexpected download table separator')
        tables = []
        for column, title in enumerate(header):
            if not title:
                if any(len(row) > column and row[column] for row in rows):
                    raise ValueError('Unexpected content in badge column')
                continue
            output = [f'| {title} |  |', '| --- | --- |']
            links = []
            for row in rows:
                if len(row) > len(header):
                    raise ValueError('Unexpected download table column')
                if column >= len(row) or not row[column]:
                    continue
                link = APK_LINK.fullmatch(row[column])
                if not link:
                    raise ValueError('Unexpected download table cell: ' + row[column])
                links.append(link.groups())
            for label, filename, family in grouped_downloads(links):
                badge = obtainium_badge(repository, family) if family else ''
                output.append(f'| [{label}]({APK_PATH}{filename}) | {badge} |')
            tables.append('\n'.join(output))
        return '\n\n'.join(tables) + ('\n' if block.endswith('\n') else '')

    body = TABLE.sub(render_markdown, body)

    # Untitled downloads use headerless HTML tables, as in the review.
    # Group adjacent download lines without swallowing headings, notes or details.
    def render_html(match):
        rows = ['<table>']
        links = [link.groups() for link in STANDALONE.finditer(match.group(0))]
        for label, filename, family in grouped_downloads(links):
            badge = ''
            if family:
                url = obtainium_url(repository, family)
                badge = f'<a href="{escape(url, quote=True)}"><img src="{BADGE}" alt="Add to Obtainium"></a>'
            rows.extend((
                '  <tr>',
                f'    <td><a href="{APK_PATH}{filename}">{escape(label)}</a></td>',
                f'    <td>{badge}</td>',
                '  </tr>',
            ))
        return '\n'.join([*rows, '</table>'])

    group = re.compile(STANDALONE.pattern + r'(?:\n[ \t]*\n' + STANDALONE.pattern + r')*', re.MULTILINE)
    return group.sub(render_html, body)


def generate_readme(readme, repository):
    # Keep the introductory text, dependency information and credits intact.
    index_start = readme.index(INDEX) + len(INDEX)
    index_end = readme.index('</details>', index_start)
    catalog_start = readme.index(MICROG, index_end)
    catalog_end = readme.index(LIBRARIES, catalog_start)
    microg, *app_sections = re.split(r'^---[ \t]*$', readme[catalog_start:catalog_end], flags=re.MULTILINE)
    apps = []
    for section in app_sections:
        section = section.strip()
        if not section:
            continue
        heading = APP_HEADING.match(section)
        if not heading or APK_PATH not in section:
            raise ValueError('Unexpected app section: ' + section.splitlines()[0])
        name = heading.group(1).rstrip(':')
        # The app is the level-three heading; its patch providers are level four.
        body = APP_HEADING.sub(lambda match: '#' + match.group(0), section[heading.end():])
        apps.append((name, heading.group(0) + render_download_tables(body, repository)))

    priority = {name.casefold(): position for position, name in enumerate(POPULAR_APPS)}
    apps.sort(key=lambda app: (priority.get(app[0].casefold(), len(priority)), app[0].casefold()))

    def index_links(group):
        return ' · '.join(f'[{name}](#{name.lower().replace(" ", "-")})' for name, _ in group)

    popular = [app for app in apps if app[0].casefold() in priority]
    others = [app for app in apps if app[0].casefold() not in priority]
    index = '\n\n'.join((
        '**Popular apps:** ' + index_links(popular),
        '**Other apps (A–Z):** ' + index_links(others),
        'Use one Add to Obtainium badge per build family to import it into '
        '[Obtainium](https://github.com/ImranR98/Obtainium). Obtainium attempts to select a '
        'compatible APK using the device CPU architecture; if it cannot narrow the choices, '
        'select a compatible APK manually. Stable, Beta and other editions remain separate.',
        'Click the architecture or variant name (e.g. Universal or Arm64-v8a) to download the APK directly.',
    ))
    intro = readme[:index_start].replace('<details>\n' + INDEX, '<details open>\n' + INDEX)
    intro += '\n\n' + index + '\n\n' + readme[index_end:catalog_start]
    catalog = '\n\n---\n\n'.join([microg.strip(), *(section for _, section in apps)])
    result = intro + catalog + '\n\n' + readme[catalog_end:]
    # Check that every download path survives the layout conversion exactly once
    # per original occurrence (including any repeated asset names).
    paths = re.compile(re.escape(APK_PATH) + r'[\w.-]+\.apk')
    if Counter(paths.findall(readme)) != Counter(paths.findall(result)):
        raise ValueError('Download paths changed while generating the catalog')
    return result


def main():
    parser = argparse.ArgumentParser(description='Refresh the README app catalog and Obtainium badges.')
    parser.add_argument('--repository', default='FiorenMas/Revanced-And-Revanced-Extended-Non-Root')
    parser.add_argument('--input', type=Path, default=ROOT / 'README.md')
    destination = parser.add_mutually_exclusive_group()
    destination.add_argument('--output', type=Path)
    destination.add_argument('--check', action='store_true', help='Fail if the input README needs regeneration.')
    args = parser.parse_args()
    if not re.fullmatch(r'[\w.-]+/[\w.-]+', args.repository):
        parser.error('--repository must be OWNER/REPO')
    original = args.input.read_text(encoding='utf-8')
    result = generate_readme(original, args.repository)
    if args.check:
        if result != original:
            parser.exit(1, 'README needs regeneration.\n')
    elif args.output:
        args.output.write_text(result, encoding='utf-8')
    else:
        print(result, end='')


if __name__ == '__main__':
    main()
