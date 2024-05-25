#!/bin/bash
# Revanced Extended for android 6 & 7 build
source src/build/utils.sh

#################################################

# Download requirements
dl_gh "revanced-patches-android6-7 revanced-integrations" "kitadai31" "latest"
dl_gh "revanced-cli" "revanced" "v3.1.1"

#################################################

# Patch YouTube Extended:
get_patches_key "youtube-revanced-extended-6-7"
version="17.34.36"
get_apk "com.google.android.youtube" "youtube" "youtube" "google-inc/youtube/youtube"
patch "youtube" "revanced-extended-android-6-7"

#################################################

# Split architecture:
rm -f revanced-cli* revanced-patches*.jar *.json
dl_gh "revanced-cli" "inotia00" "latest"
dl_gh "revanced-patches" "inotia00" "latest"
# Split architecture Youtube:
for i in {0..3}; do
    split_arch "youtube-revanced-extended-android-6-7" "youtube-${archs[i]}-revanced-extended-android-6-7" "$(_gen_rip_libs ${_libs[i]})"
done

#################################################