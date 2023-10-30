#!/bin/bash
# Revanced Extended build
source src/build/utils.sh

#################################################

# Checking new patch
checker "inotia00/revanced-patches" "revanced-extended"

#################################################

# Download requirements
dl_gh "revanced-patches revanced-integrations revanced-cli" "inotia00" "latest"

#################################################

# Patch YouTube Extended:
get_patches_key "youtube-revanced-extended"
get_ver "Hide general ads" "com.google.android.youtube"
get_apk "youtube" "youtube" "google-inc/youtube/youtube"
patch "youtube" "revanced-extended" "inotia"

#################################################

# Patch YouTube Music Extended:
# Arm64-v8a
get_patches_key "youtube-music-revanced-extended"
get_ver "Hide music ads" "com.google.android.apps.youtube.music"
get_apk "youtube-music-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
patch "youtube-music-arm64-v8a" "revanced-extended" "inotia"
# Armeabi-v7a
get_patches_key "youtube-music-revanced-extended"
get_ver "Hide music ads" "com.google.android.apps.youtube.music"
get_apk "youtube-music-armeabi-v7a" "youtube-music" "google-inc/youtube-music/youtube-music" "armeabi-v7a"
patch "youtube-music-armeabi-v7a" "revanced-extended" "inotia"

#################################################

# Patch Reddit:
get_patches_key "reddit"
get_apk "reddit" "reddit" "redditinc/reddit/reddit"
patch "reddit" "revanced-extended" "inotia"

#################################################

# Split architecture:
rm -f revanced-cli* revanced-patches*.jar patches.json 
dl_gh "revanced-cli" "j-hc" "latest"
dl_gh "revanced-patches" "revanced" "latest"
# Split architecture Youtube:
for i in {0..3}; do
    split_arch "youtube-revanced-extended" "youtube-${archs[i]}-revanced-extended" "$(gen_rip_libs ${libs[i]})"
done

#################################################
