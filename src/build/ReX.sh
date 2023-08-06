#!/bin/bash
# Revanced Extended build
source src/build/utils.sh

#################################################

# Checking new patch
checker "YT-Advanced/ReX-patches" "ReX"

#################################################

# Download requirements
dl_gh "ReX-patches ReX-integrations" "YT-Advanced" "latest"
dl_gh "revanced-cli" "inotia00" "latest"
dl_htmlq

#################################################

# Patch YouTube Extended:
get_patches_key "youtube-ReX"
get_ver "Hide general ads" "com.google.android.youtube"
get_apk "youtube" "youtube" "google-inc/youtube/youtube"
patch "youtube" "youtube-ReX"

#################################################

# Patch YouTube Music Extended:
# Arm64-v8a
get_patches_key "youtube-music-ReX"
get_apk "youtube-music-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
patch "youtube-music-arm64-v8a" "youtube-music-arm64-v8a-ReX"
# Armeabi-v7a
get_patches_key "youtube-music-ReX"
version="6.08.51"
get_apk "youtube-music-armeabi-v7a" "youtube-music" "google-inc/youtube-music/youtube-music" "armeabi-v7a"
patch "youtube-music-armeabi-v7a" "youtube-music-armeabi-v7a-ReX"

#################################################

# Patch Reddit:
get_patches_key "reddit"
get_apk "reddit" "reddit" "redditinc/reddit/reddit"
patch "reddit" "reddit-ReX"

#################################################

# Split architecture:
rm -f revanced-cli*
dl_gh "revanced-cli" "j-hc" "latest"
# Split architecture Youtube:
for i in {0..3}; do
    split_arch "youtube-ReX" "youtube-${archs[i]}-ReX" "$(gen_rip_libs ${libs[i]})"
done

#################################################
