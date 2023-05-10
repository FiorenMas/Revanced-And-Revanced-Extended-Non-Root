#!/bin/bash
# Revanced Extended build
source src/build/tools.sh

release=$(curl -s "https://api.github.com/repos/inotia00/revanced-patches/releases/latest")
asset=$(echo "$release" | jq -r '.assets[] | select(.name | test("revanced-patches.*\\.jar$")) | .browser_download_url')
curl -sL -O "$asset"
ls revanced-patches*.jar >> new.txt
rm -f revanced-patches*.jar
release=$(curl -s "https://api.github.com/repos/FiorenMas/Revanced-And-Revanced-Extended-Non-Root/releases/latest")
asset=$(echo "$release" | jq -r '.assets[] | select(.name == "revanced-extended-version.txt") | .browser_download_url')
curl -sL -O "$asset"
if diff -q revanced-extended-version.txt new.txt >/dev/null ; then
echo "Old patch!!! Not build"
exit 0
else
rm -f *.txt

dl_gh "revanced-patches revanced-integrations" "inotia00" "latest"
dl_gh "revanced-cli" "j-hc" "latest"

# Patch YouTube Extended
get_patches_key "youtube-revanced-extended"
#version=""
get_ver "hide-general-ads" "com.google.android.youtube"
get_apk "youtube" "youtube" "google-inc/youtube/youtube"
patch "youtube" "youtube-revanced-extended"
change_arch "youtube-revanced-extended" "youtube-revanced-extended-arm64-v8a" "--rip-lib x86_64 --rip-lib x86 --rip-lib armeabi-v7a"
change_arch "youtube-revanced-extended" "youtube-revanced-extended-armeabi-v7a" "--rip-lib x86_64 --rip-lib x86 --rip-lib arm64-v8a"
change_arch "youtube-revanced-extended" "youtube-revanced-extended-x86_64" "--rip-lib x86 --rip-lib armeabi-v7a --rip-lib arm64-v8a"
change_arch "youtube-revanced-extended" "youtube-revanced-extended-x86" "--rip-lib x86_64 --rip-lib armeabi-v7a --rip-lib arm64-v8a"

dl_gh "revanced-patches revanced-cli revanced-integrations" "inotia00" "latest"

# Patch YouTube Music Extended 
get_patches_key "youtube-music-revanced-extended"
get_apk_arch "youtube-music" "youtube-music" "google-inc/youtube-music/youtube-music"
patch "youtube-music" "youtube-music-revanced-extended"

ls revanced-patches*.jar >> revanced-extended-version.txt
fi
