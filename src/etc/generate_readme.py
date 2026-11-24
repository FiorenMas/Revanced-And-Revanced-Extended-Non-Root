import argparse
import hashlib
import json
import re
from pathlib import Path
from urllib.parse import quote


ROOT = Path(__file__).resolve().parents[2]
INDEX = '  <summary><h2>List of available apps</h2></summary>'
MICROG = '## [MicroG RE:]'
LIBRARIES = '### ⚠️ Libraries and resources used in this repository:'
APK_LINK = re.compile(r'\[([^\]\n]+)\]\(\.\./\.\./releases/download/all/([\w.-]+\.apk)\s*\)')
APP_HEADING = re.compile(r'^### \[([^\]]+)\]\([^\n]*\)$', re.MULTILINE)
BADGE = 'https://img.shields.io/badge/Add_to-Obtainium-2D7D46'
REDIRECT = 'https://apps.obtainium.imranr.dev/redirect?r='
GENERATED_BADGE = re.compile(r' \[!\[Add to Obtainium\]\(' + re.escape(BADGE) + r'\)\]\(' + re.escape(REDIRECT) + r'[^\s)]+\)')


def obtainium_badge(repository, filename):
    url = f'https://github.com/{repository}'
    name = filename.removesuffix('.apk')
    settings = {
        'apkFilterRegEx': '^' + re.escape(filename) + '$',
        'autoApkFilterByArch': False,
        'useLatestAssetDateAsReleaseDate': True,
        'releaseDateAsVersion': True,
        'versionDetection': False,
        'appName': name,
    }
    config = {
        'id': hashlib.sha256(f'{url}/{filename}'.encode()).hexdigest()[:12],
        'url': url,
        'author': repository.split('/')[0],
        'name': name,
        'additionalSettings': json.dumps(settings, separators=(',', ':')),
        'overrideSource': 'GitHub',
        'allowIdChange': True,
    }
    payload = quote(json.dumps(config, separators=(',', ':')), safe='')
    return f'[![Add to Obtainium]({BADGE})]({REDIRECT}obtainium://app/{payload})'


def generate_readme(readme, repository):
    # Keep the introductory text, dependency information and credits intact.
    index_start = readme.index(INDEX) + len(INDEX)
    index_end = readme.index('</details>', index_start)
    catalog_start = readme.index(MICROG, index_end)
    catalog_end = readme.index(LIBRARIES, catalog_start)
    microg, *app_sections = re.split(r'^---\s*$', readme[catalog_start:catalog_end], flags=re.MULTILINE)
    apps = []
    for section in app_sections:
        section = section.strip()
        if not section:
            continue
        heading = APP_HEADING.match(section)
        if not heading or not APK_LINK.search(section):
            raise ValueError('Unexpected app section: ' + section.splitlines()[0])
        name = heading.group(1).rstrip(':')
        # The app is the level-three heading; its patch providers are level four.
        body = APP_HEADING.sub(lambda match: '#' + match.group(0), section[heading.end():])
        body = GENERATED_BADGE.sub('', body)
        body = APK_LINK.sub(
            lambda match: f'{match.group(0)} {obtainium_badge(repository, match.group(2))}',
            body,
        )
        # Retain the original store link and provider notes.
        apps.append((name, heading.group(0) + body))

    apps.sort(key=lambda app: app[0].casefold())
    # GitHub derives heading anchors from the visible heading text.
    index = ' · '.join(f'[{name}](#{name.lower().replace(" ", "-")})' for name, _ in apps)
    intro = readme[:index_start].replace('<details>\n' + INDEX, '<details open>\n' + INDEX)
    intro += '\n\n' + index + '\n\n' + readme[index_end:catalog_start]
    catalog = '\n\n---\n\n'.join([microg.strip(), *(section for _, section in apps)])
    return intro + catalog + '\n\n' + readme[catalog_end:]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--repository', default='FiorenMas/Revanced-And-Revanced-Extended-Non-Root')
    parser.add_argument('--input', type=Path, default=ROOT / 'README.md')
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    if not re.fullmatch(r'[\w.-]+/[\w.-]+', args.repository):
        parser.error('--repository must be OWNER/REPO')
    result = generate_readme(args.input.read_text(encoding='utf-8'), args.repository)
    if args.output:
        args.output.write_text(result, encoding='utf-8')
    else:
        print(result, end='')


if __name__ == '__main__':
    main()
