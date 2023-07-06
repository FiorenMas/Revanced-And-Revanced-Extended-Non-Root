#!/bin/bash
# Revanced Extended for android 6 & 7 build
source src/build/utils.sh

#################################################

# Checking new patch
checker "kitadai31/revanced-patches-android6-7" "revanced-extended-android-6-7"

#################################################

# Download requirement patches
dl_gh "revanced-patches-android6-7 revanced-integrations" "kitadai31" "latest"
dl_gh "revanced-cli" "inotia00" "latest"

#################################################

# Patch YouTube Extended:
get_patches_key "youtube-revanced-extended-6-7"
version="17.34.36"
#get_ver "hide-general-ads" "com.google.android.youtube"
get_apk "youtube" "youtube" "google-inc/youtube/youtube"
patch "youtube" "youtube-revanced-extended-android-6-7"

#################################################

# Split architecture:
rm -f revanced-cli*
dl_gh "revanced-cli" "j-hc" "latest"
# Split architecture Youtube:
for i in {0..3}; do
    split_arch "youtube-revanced-extended-android-6-7" "youtube-${archs[i]}-revanced-extended-android-6-7" "$(gen_rip_libs ${libs[i]})"
done

#################################################