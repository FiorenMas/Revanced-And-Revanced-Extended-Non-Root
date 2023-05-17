#!/bin/bash
# Revanced Extended build
source src/build/tools.sh

curl -sL -O $(curl -s "https://api.github.com/repos/inotia00/revanced-patches/releases/latest" | jq -r '.assets[] | select(.name | test("revanced-patches.*\\.jar$")) | .browser_download_url')
ls revanced-patches*.jar >> new.txt
curl -sL -O $(curl -s "https://api.github.com/repos/$repository/releases/latest" | jq -r '.assets[] | select(.name == "revanced-version.txt") | .browser_download_url')
if diff -q revanced-version.txt new.txt >/dev/null ; then
rm -f revanced-patches*.jar *.txt
echo "Old patch!!! Not build"
exit 0
else

dl_gh "revanced-patches revanced-cli revanced-integrations" "inotia00" "latest"

# Patch YouTube Extended
get_patches_key "youtube-revanced-extended"
version="18.17.43"
#get_ver "hide-general-ads" "com.google.android.youtube"
get_apk "youtube" "youtube" "google-inc/youtube/youtube"
patch "youtube" "youtube-revanced-extended"

# Patch YouTube Music Extended 
get_patches_key "youtube-music-revanced-extended"
version="6.01.55"
get_apk_arch "youtube-music" "youtube-music" "google-inc/youtube-music/youtube-music"
patch "youtube-music" "youtube-music-revanced-extended"

# Change architecture
rm -f revanced-cli*
dl_gh "revanced-cli" "j-hc" "latest"
for i in {0..3}; do
    change_arch "youtube-revanced-extended" "youtube-revanced-extended-${archs[i]}" "$(gen_rip_libs ${libs[i]})"
done

ls revanced-patches*.jar >> revanced-extended-version.txt
fi
