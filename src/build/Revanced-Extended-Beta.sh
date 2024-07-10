#!/bin/bash
# Revanced Extended build
source src/build/utils.sh

#################################################

# Download requirements
dl_gh "revanced-patches revanced-integrations" "inotia00" "prerelease"
dl_gh "revanced-cli" "inotia00" "latest"

#################################################

# Patch YouTube Extended:
get_patches_key "youtube-revanced-extended"
get_apk "com.google.android.youtube" "youtube-beta" "youtube" "google-inc/youtube/youtube"
patch "youtube-beta" "revanced-extended" "inotia"

#################################################

# Patch YouTube Music Extended:
# Arm64-v8a
get_patches_key "youtube-music-revanced-extended"
get_apk "com.google.android.apps.youtube.music" "youtube-music-beta-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
patch "youtube-music-beta-arm64-v8a" "revanced-extended" "inotia"
# Armeabi-v7a
get_patches_key "youtube-music-revanced-extended"
get_apk "com.google.android.apps.youtube.music" "youtube-music-beta-armeabi-v7a" "youtube-music" "google-inc/youtube-music/youtube-music" "armeabi-v7a"
patch "youtube-music-beta-armeabi-v7a" "revanced-extended" "inotia"

#################################################

# Split architecture Youtube:
for i in {0..3}; do
    split_arch "youtube-beta-revanced-extended" "youtube-beta-${archs[i]}-revanced-extended" "$(gen_rip_libs ${libs[i]})"
done