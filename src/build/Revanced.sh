#!/bin/bash
# Revanced build
source ./src/build/utils.sh

#################################################

# Checking new patch
checker "revanced/revanced-patches" "revanced"

#################################################

# Download requirements
dl_gh "revanced-patches revanced-cli revanced-integrations" "revanced" "latest"
dl_htmlq

#################################################

# Patch YouTube:
#get_patches_key "youtube-revanced"
#get_ver "Video ads" "com.google.android.youtube"
#get_apk "youtube" "youtube" "google-inc/youtube/youtube"
#patch "youtube" "youtube-revanced"

#################################################

# Patch YouTube Music:
# Arm64-v8a
get_patches_key "youtube-music-revanced"
version="6.10.51"
get_apk "youtube-music-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
patch "youtube-music-arm64-v8a" "youtube-music-arm64-v8a-revanced"
# Armeabi-v7a
get_patches_key "youtube-music-revanced"
version="6.08.51"
get_apk "youtube-music-armeabi-v7a" "youtube-music" "google-inc/youtube-music/youtube-music" "armeabi-v7a"
patch "youtube-music-armeabi-v7a" "youtube-music-armeabi-v7a-revanced"

#################################################

# Patch Instagram:
# Arm64-v8a
get_patches_key "instagram"
get_ver "Hide timeline ads" "com.instagram.android"
get_apk "instagram-arm64-v8a" "instagram-instagram" "instagram/instagram-instagram/instagram-instagram" "arm64-v8a"
patch "instagram-arm64-v8a" "instagram-arm64-v8a-revanced"

#################################################

# Patch Messenger:
# Arm64-v8a
get_patches_key "messenger"
get_apk "messenger-arm64-v8a" "messenger" "facebook-2/messenger/messenger" "arm64-v8a"
patch "messenger-arm64-v8a" "messenger-arm64-v8a-revanced"
# Armeabi-v7a
get_patches_key "messenger"
get_apk "messenger-armeabi-v7a" "messenger" "facebook-2/messenger/messenger" "armeabi-v7a"
patch "messenger-armeabi-v7a" "messenger-armeabi-v7a-revanced"

#################################################

# Patch Twitter:
get_patches_key "twitter"
version="9.97.0-release.0"
get_apk "twitter" "twitter" "twitter-inc/twitter/twitter"
patch "twitter" "twitter-revanced"

#################################################

# Patch Twitch:
get_patches_key "twitch"
get_ver "Block video ads" "tv.twitch.android.app"
get_apk "twitch" "twitch" "twitch-interactive-inc/twitch/twitch"
patch "twitch" "twitch-revanced"

#################################################

# Patch Reddit:
get_patches_key "reddit"
get_apk "reddit" "reddit" "redditinc/reddit/reddit"
patch "reddit" "reddit-revanced"

#################################################

# Patch Tiktok:
get_patches_key "tiktok"
version="30.5.2"
get_apk "tiktok" "tik-tok-including-musical-ly" "tiktok-pte-ltd/tik-tok-including-musical-ly/tik-tok-including-musical-ly"
patch "tiktok" "tiktok-revanced"

#################################################

# Patch Pixiv:
get_patches_key "pixiv"
#get_ver "Hide ads" "jp.pxv.android"
get_apk "pixiv" "pixiv" "pixiv-inc/pixiv/pixiv"
patch "pixiv" "pixiv-revanced"

#################################################

# Patch Windy:
get_patches_key "windy"
get_apk "windy" "windy-wind-weather-forecast" "windy-weather-world-inc/windy-wind-weather-forecast/windy-wind-weather-forecast"
patch "windy" "windy-revanced"

#################################################

# Split architecture:
rm -f revanced-cli*.jar
dl_gh "revanced-cli" "j-hc" "latest"
# Split architecture Youtube:
for i in {0..3}; do
    split_arch "youtube-revanced" "youtube-${archs[i]}-revanced" "$(gen_rip_libs ${libs[i]})"
done

#################################################

# Patch Instagram:
# Armeabi-v7a
rm -f patches*.json revanced-patches*.jar revanced-integrations*.apk revanced-cli*.jar
dl_gh "revanced-patches" "revanced" "tags/v2.175.0"
dl_gh "revanced-integrations" "revanced" "tags/v0.109.0"
dl_gh "revanced-cli" "revanced" "tags/v2.21.2"
get_patches_key "instagram"
version="271.1.0.21.84"
get_apk "instagram-armeabi-v7a" "instagram-instagram" "instagram/instagram-instagram/instagram-instagram" "armeabi-v7a"
patch "instagram-armeabi-v7a" "instagram-armeabi-v7a-revanced"

#################################################
