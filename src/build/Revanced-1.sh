#!/bin/bash
# Revanced build
source ./src/build/utils.sh

#################################################

# Download requirements
dl_gh "revanced-patches revanced-cli revanced-integrations" "revanced" "latest"

#################################################

# Patch YouTube:
get_patches_key "youtube-revanced"
get_apk "com.google.android.youtube" "youtube" "youtube" "google-inc/youtube/youtube"
patch "youtube" "revanced"

#################################################

# Patch YouTube Music:
# Arm64-v8a
get_patches_key "youtube-music-revanced"
get_apk "com.google.android.apps.youtube.music" "youtube-music-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
patch "youtube-music-arm64-v8a" "revanced"
# Armeabi-v7a
get_patches_key "youtube-music-revanced"
get_apk "com.google.android.apps.youtube.music" "youtube-music-armeabi-v7a" "youtube-music" "google-inc/youtube-music/youtube-music" "armeabi-v7a"
patch "youtube-music-armeabi-v7a" "revanced"

#################################################

# Patch Instagram:
# Arm64-v8a
get_patches_key "instagram"
get_apk "com.instagram.android" "instagram-arm64-v8a" "instagram-instagram" "instagram/instagram-instagram/instagram-instagram" "arm64-v8a" "nodpi"
patch "instagram-arm64-v8a" "revanced"

#################################################

# Patch Messenger:
# Arm64-v8a
get_patches_key "messenger"
get_apk "com.facebook.orca" "messenger-arm64-v8a" "messenger" "facebook-2/messenger/messenger" "arm64-v8a" "nodpi"
patch "messenger-arm64-v8a" "revanced"

#################################################

# Split architecture:
rm -f revanced-cli* revanced-patches*.jar *.json 
dl_gh "revanced-cli" "inotia00" "latest"
dl_gh "revanced-patches" "inotia00" "latest"
# Split architecture Youtube:
for i in {0..3}; do
    split_arch "youtube-revanced" "youtube-${archs[i]}-revanced" "$(gen_rip_libs ${libs[i]})"
done

#################################################