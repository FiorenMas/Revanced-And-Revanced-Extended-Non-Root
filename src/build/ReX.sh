#!/bin/bash
# ReX build
source src/build/utils.sh

#################################################

# Download requirements
dl_gh "ReX-patches ReX-integrations" "YT-Advanced" "latest"
dl_gh "revanced-cli" "inotia00" "latest"

#################################################

# Patch YouTube ReX:
get_patches_key "youtube-ReX"
get_ver "Hide general ads" "com.google.android.youtube"
get_apk "youtube" "youtube" "google-inc/youtube/youtube"
patch "youtube" "ReX" "inotia"

#################################################

# Patch YouTube Music ReX:
# Arm64-v8a
get_patches_key "youtube-music-ReX"
get_ver "Enable color match player" "com.google.android.apps.youtube.music"
get_apk "youtube-music-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
patch "youtube-music-arm64-v8a" "ReX" "inotia"
# Armeabi-v7a
get_patches_key "youtube-music-ReX"
get_ver "Enable color match player" "com.google.android.apps.youtube.music"
get_apk "youtube-music-armeabi-v7a" "youtube-music" "google-inc/youtube-music/youtube-music" "armeabi-v7a"
patch "youtube-music-armeabi-v7a" "ReX" "inotia"

#################################################

# Patch Reddit:
get_patches_key "reddit"
get_apk "reddit" "reddit" "redditinc/reddit/reddit"
patch "reddit" "ReX" "inotia"

#################################################

rm -f revanced-cli*
dl_gh "revanced-cli" "FiorenMas" "latest"
# Split architecture Youtube:
get_patches_key "youtube-ReX"
for i in {0..3}; do
    split_arch "youtube" "youtube-${archs[i]}-ReX" "$(gen_rip_libs ${libs[i]})"
done

#################################################
