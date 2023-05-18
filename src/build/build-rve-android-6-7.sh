#!/bin/bash
# Revanced Extended for android 6 & 7 build
source src/build/tools.sh

curl -sL -O $(curl -s "https://api.github.com/repos/kitadai31/revanced-patches-android6-7/releases/latest" | jq -r '.assets[] | select(.name | test("revanced-patches.*\\.jar$")) | .browser_download_url')
ls revanced-patches*.jar >> new.txt
curl -sL -O $(curl -s "https://api.github.com/repos/$repository/releases/latest" | jq -r '.assets[] | select(.name == "revanced-version.txt") | .browser_download_url')
if diff -q revanced-version.txt new.txt >/dev/null ; then
rm -f ./revanced-patches*.jar ./*.txt
echo "Old patch!!! Not build"
exit 0
else

dl_gh "revanced-patches-android6-7 revanced-integrations" "kitadai31" "latest"
dl_gh "revanced-cli" "inotia00" "latest"

# Patch YouTube Extended
get_patches_key "youtube-revanced-extended-6-7"
version="17.34.36"
#get_ver "hide-general-ads" "com.google.android.youtube"
get_apk "youtube" "youtube" "google-inc/youtube/youtube"
patch "youtube" "youtube-revanced-extended-android-6-7"

# Change architecture
rm -f ./revanced-cli*
dl_gh "revanced-cli" "j-hc" "latest"
for i in {0..3}; do
	change_arch "youtube-revanced-extended-android-6-7" "youtube-revanced-extended-android-6-7-${archs[i]}" "$(gen_rip_libs "${libs[i]}")"
done

ls revanced-patches*.jar >> revanced-extended-android-6-7-version.txt
fi
