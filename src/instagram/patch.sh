#!/bin/bash
DIR_TMP="$(mktemp -d)"

echo "⏬ Downloading Revanced resources..."
for repos in revanced-patches revanced-cli revanced-integrations; do
    curl -s "https://api.github.com/repos/revanced/$repos/releases/latest" | jq -r '.assets[].browser_download_url' | xargs -n 1 curl -sL -O
done

echo "⚙️ Importing Patches..."
EXCLUDE_PATCHES=()
for word in $(cat src/instagram/exclude-patches.txt) ; do
    EXCLUDE_PATCHES+=("-e $word")
done

echo "⏬ Downloading apkeep resources..."
curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL github.com/EFForg/apkeep/releases/latest/download/apkeep-x86_64-unknown-linux-gnu -o ${DIR_TMP}/apkeep

echo "⏬ Downloading Instagram..."
chmod +x ${DIR_TMP}/apkeep
${DIR_TMP}/apkeep -a com.instagram.android@271.1.0.21.84 .

echo "⚙️ Patching Instagram..."
java -jar revanced-cli*.jar -m revanced-integrations*.apk -b revanced-patches*.jar ${EXCLUDE_PATCHES[@]} -a com.instagram.android@271.1.0.21.84.apk --keystore=ks.keystore -o Instagram.apk
