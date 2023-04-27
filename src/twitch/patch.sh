#!/bin/bash
DIR_TMP="$(mktemp -d)"
for repos in revanced-patches revanced-cli revanced-integrations; do
    curl -s "https://api.github.com/repos/revanced/$repos/releases/latest" | jq -r '.assets[].browser_download_url' | xargs -n 1 curl -sL -O
done
EXCLUDE_PATCHES=()
for word in $(cat src/twitch/exclude-patches.txt) ; do
    EXCLUDE_PATCHES+=("-e $word")
done
version=$(jq -r '.[] | select(.name == "block-video-ads") | .compatiblePackages[] | select(.name == "tv.twitch.android.app") | .versions[-1]' patches.json)
curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL github.com/EFForg/apkeep/releases/latest/download/apkeep-x86_64-unknown-linux-gnu -o ${DIR_TMP}/apkkeep
chmod +x ${DIR_TMP}/apkkeep && ${DIR_TMP}/apkkeep -a tv.twitch.android.app@$version .
java -jar revanced-cli*.jar -m revanced-integrations*.apk -b revanced-patches*.jar ${EXCLUDE_PATCHES[@]} -a tv.twitch.android.app*.apk --keystore=ks.keystore -o Twitch.apk