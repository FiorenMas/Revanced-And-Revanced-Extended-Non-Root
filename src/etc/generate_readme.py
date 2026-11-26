import argparse
from base64 import b64encode
from collections import Counter
import hashlib
from html import escape, unescape
import json
import re
from pathlib import Path
from urllib.parse import quote


# Keep these apps at the top of both the index and download catalog.
POPULAR_APPS = ('YouTube', 'YouTube Music', 'Facebook', 'Instagram', 'Threads')

# App badges from the compact jump index in PR #189 and its follow-ups.
# Use named Simple Icons logos where available and self-contained pictograms
# elsewhere. See https://shields.io/docs/logos for custom logo support.
def icon_badge(label, path, color='475569'):
    svg = (
        '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">'
        f'<path d="{path}" fill="none" stroke="white" stroke-width="2" '
        'stroke-linecap="round" stroke-linejoin="round"/></svg>'
    )
    logo = quote('data:image/svg+xml;base64,' + b64encode(svg.encode()).decode(), safe='')
    label = quote(label.replace('-', '--').replace('_', '__'), safe='')
    return f'{label}-{color}?style=for-the-badge&logo={logo}'


APP_ICON = 'M3 3h7v7H3zM14 3h7v7h-7zM3 14h7v7H3zM14 14h7v7h-7z'


APP_BADGES = {
    'youtube': 'YouTube-%23FF0000.svg?style=for-the-badge&logo=YouTube&logoColor=white',
    'youtube-music': 'YouTube_Music-FF0000?style=for-the-badge&logo=youtubemusic&logoColor=white',
    'facebook': 'Facebook-%231877F2.svg?style=for-the-badge&logo=Facebook&logoColor=white',
    'messenger': 'Messenger-00B2FF?style=for-the-badge&logo=messenger&logoColor=white',
    'twitter': 'Twitter-%231DA1F2.svg?style=for-the-badge&logo=x&logoColor=white',
    'instagram': 'Instagram-%23E4405F.svg?style=for-the-badge&logo=Instagram&logoColor=white',
    'threads': 'Threads-000000?style=for-the-badge&logo=Threads&logoColor=white',
    'tiktok': 'TikTok-%23000000.svg?style=for-the-badge&logo=TikTok&logoColor=white',
    'twitch': 'Twitch-%239146FF.svg?style=for-the-badge&logo=Twitch&logoColor=white',
    'reddit': 'Reddit-%23FF4500.svg?style=for-the-badge&logo=Reddit&logoColor=white',
    'pinterest': 'Pinterest-%23E60023.svg?style=for-the-badge&logo=Pinterest&logoColor=white',
    'lightroom': icon_badge('Adobe Lightroom', 'M4 4h16v16H4zM8 8v8h5M15 16v-6M15 12q1-2 3-2', '31A8FF'),
    'tumblr': 'Tumblr-%2336465D.svg?style=for-the-badge&logo=Tumblr&logoColor=white',
    'soundcloud': 'soundcloud-FF5500?style=for-the-badge&logo=soundcloud&logoColor=white',
    'duolingo': 'Duolingo-%234DC730.svg?style=for-the-badge&logo=Duolingo&logoColor=white',
    'viber': 'Viber-8B66A9?style=for-the-badge&logo=viber&logoColor=white',
    'discord': 'Discord-%235865F2.svg?style=for-the-badge&logo=discord&logoColor=white',
    'proton-mail': 'ProtonMail-8B89CC?style=for-the-badge&logo=protonmail&logoColor=white',
    'prime-video': icon_badge('Amazon Prime', 'M3 4h18v16H3zM10 8l6 4-6 4z', '0F79AF'),
    'telegram': 'Telegram-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white',
    'adguard': 'Adguard-387D44?style=for-the-badge&logo=adguard&logoColor=white',
    'amazon-shopping': icon_badge('Amazon Shopping', 'M3 4h2l3 11h11l2-8H6M9 20h.1M18 20h.1'),
    'battery-guru': icon_badge('Battery Guru', 'M2 6h18v12H2zM22 10v4M12 8l-3 4h5l-3 4'),
    'brave-browser': 'Brave_Browser-FB542B?style=for-the-badge&logo=brave&logoColor=white',
    'camscanner': icon_badge('CamScanner', 'M3 8V3h5M16 3h5v5M21 16v5h-5M8 21H3v-5M7 8h10M7 12h10M7 16h6'),
    'eyeconcaller': icon_badge('EyeconCaller', 'M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12zM12 9a3 3 0 1 0 0 6 3 3 0 0 0 0-6z'),
    'fx-file-explorer': icon_badge('FX File Explorer', 'M3 6h7l2 3h9v11H3zM7 14h10'),
    'google-news': 'Google_News-174EA6?style=for-the-badge&logo=googlenews&logoColor=white',
    'google-photos': 'Google_Photos-4285F4?style=for-the-badge&logo=googlephotos&logoColor=white',
    'google-recorder': icon_badge('Google Recorder', 'M9 5a3 3 0 0 1 6 0v7a3 3 0 0 1-6 0zM5 11v1a7 7 0 0 0 14 0v-1M12 19v3M9 22h6'),
    'myfitnesspal': icon_badge('MyFitnessPal', 'M3 9v6M6 6v12M6 12h12M18 6v12M21 9v6'),
    'nova-launcher': icon_badge('Nova Launcher', 'M12 2l2.5 7.5L22 12l-7.5 2.5L12 22l-2.5-7.5L2 12l7.5-2.5z'),
    'photomath': icon_badge('Photomath', 'M3 8V3h5M16 3h5v5M21 16v5h-5M8 21H3v-5M8 12h8M12 8v8'),
    'pixiv': 'Pixiv-0096FA?style=for-the-badge&logo=pixiv&logoColor=white',
    'proton-vpn': 'Proton_VPN-6D4AFF?style=for-the-badge&logo=protonvpn&logoColor=white',
    'psiphon': icon_badge('Psiphon', 'M12 3l8 3v6c0 5-4 8-8 10-4-2-8-5-8-10V6zM8 12l3 3 5-6'),
    'rar': icon_badge('RAR', 'M4 3h16v18H4zM12 3v3h2v3h-2v3h2v3h-2v3'),
    'smart-launcher': icon_badge('Smart Launcher', 'M12 3l9 5-9 5-9-5zM3 12l9 5 9-5M3 16l9 5 9-5'),
    'solid-explorer-file-manager': icon_badge('Solid Explorer File Manager', 'M2 5h8l2 3h10l-3 12H2zM2 11h19'),
    'strava': 'Strava-FC5200?style=for-the-badge&logo=strava&logoColor=white',
    'tasker': icon_badge('Tasker', 'M7 3h10v18H7zM9 12l2 2 4-5'),
    'terabox': icon_badge('TeraBox', 'M6 19h12a4 4 0 0 0 1-8 7 7 0 0 0-13-2 5 5 0 0 0 0 10zM12 15V9M9 12l3-3 3 3'),
    'tiktok-asia': 'TikTok_Asia-000000?style=for-the-badge&logo=tiktok&logoColor=white',
    'truecaller': icon_badge('Truecaller', 'M4 4h5l2 5-3 2q2 4 6 5l2-3 5 2v5C11 22 2 13 4 4z'),
    'waze': 'Waze-33CCFF?style=for-the-badge&logo=waze&logoColor=black',
    'windscribe': icon_badge('Windscribe', 'M3 7h12a2 2 0 1 0-2-2M3 12h17a2 2 0 1 1-2 2M3 17h11a2 2 0 1 1-2 2'),
    'wps-office': icon_badge('WPS Office', 'M5 3h9l5 5v13H5zM14 3v5h5M8 12h8M8 16h8'),
    'zalo': 'Zalo-0068FF?style=for-the-badge&logo=zalo&logoColor=white',
}

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

    badges = []
    for name, _ in apps:
        anchor = name.lower().replace(" ", "-")
        badge = APP_BADGES.get(anchor)
        if badge is None:
            badge = icon_badge(name, APP_ICON)
        badges.append(f'[![{name}](https://img.shields.io/badge/{badge})](#{anchor})')

    index = '\n\n'.join((
        '**Jump to an app**',
        '\n'.join(badges),
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
