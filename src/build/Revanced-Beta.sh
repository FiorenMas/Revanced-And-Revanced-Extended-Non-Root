#!/bin/bash
# Revanced build
source ./src/build/utils.sh

#################################################

# Download requirements
dl_gh "revanced-patches revanced-integrations" "revanced" "prerelease"
dl_gh "revanced-cli" "revanced" "latest"

#################################################

# Patch YouTube:
get_patches_key "youtube-revanced"
get_ver "Video ads" "com.google.android.youtube"
get_apk "youtube-beta" "youtube" "google-inc/youtube/youtube"
patch "youtube-beta" "revanced"

#################################################

# Patch YouTube Music:
# Arm64-v8a
get_patches_key "youtube-music-revanced"
get_apk "youtube-music-beta-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
patch "youtube-music-beta-arm64-v8a" "revanced"
# Armeabi-v7a
get_patches_key "youtube-music-revanced"
get_apk "youtube-music-beta-armeabi-v7a" "youtube-music" "google-inc/youtube-music/youtube-music" "armeabi-v7a"
patch "youtube-music-beta-armeabi-v7a" "revanced"

#################################################

# Split architecture:
rm -f revanced-cli* revanced-patches*.jar patches.json 
dl_gh "revanced-patches" "revanced" "prerelease"
dl_gh "revanced-cli" "FiorenMas" "latest"
# Split architecture Youtube:
get_patches_key "youtube-revanced"
for i in {0..3}; do
    split_arch "youtube-beta" "youtube-beta-${archs[i]}-revanced" "$(gen_rip_libs ${libs[i]})"
done

#################################################