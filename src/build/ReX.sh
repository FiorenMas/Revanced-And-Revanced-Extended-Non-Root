#!/bin/bash
# ReX build
source src/build/utils.sh

#################################################

# Download requirements
dl_gh "ReX-patches ReX-integrations" "YT-Advanced" "latest"
dl_gh "revanced-cli" "revanced" "latest"

#################################################

# Patch YouTube ReX:
get_patches_key "youtube-ReX"
get_apk "com.google.android.youtube" "youtube" "youtube" "google-inc/youtube/youtube"
patch "youtube" "ReX"

#################################################

# Patch YouTube Music ReX:
# Arm64-v8a
get_patches_key "youtube-music-ReX"
get_apk "com.google.android.apps.youtube.music" "youtube-music-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
patch "youtube-music-arm64-v8a" "ReX"
# Armeabi-v7a
get_patches_key "youtube-music-ReX"
get_apk "com.google.android.apps.youtube.music" "youtube-music-armeabi-v7a" "youtube-music" "google-inc/youtube-music/youtube-music" "armeabi-v7a"
patch "youtube-music-armeabi-v7a" "ReX"

#################################################

# Split architecture:
rm -f revanced-cli* revanced-patches*.jar *.json
dl_gh "revanced-cli" "inotia00" "latest"
dl_gh "revanced-patches" "inotia00" "latest"
# Split architecture Youtube:
get_patches_key "youtube-ReX"
for i in {0..3}; do
    split_arch "youtube-ReX" "youtube-${archs[i]}-ReX" "$(gen_rip_libs ${libs[i]})"
done

#################################################