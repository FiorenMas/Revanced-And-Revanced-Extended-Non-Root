#!/bin/bash
# Revanced build
source src/build/utils.sh

release=$(curl -s "https://api.github.com/repos/revanced/revanced-patches/releases/latest")
asset=$(echo "$release" | jq -r '.assets[] | select(.name | test("revanced-patches.*\\.jar$")) | .browser_download_url')
curl -sL -O "$asset"
ls revanced-patches*.jar >> new.txt
rm -f revanced-patches*.jar
release=$(curl -s "https://api.github.com/repos/$repository/releases/latest")
asset=$(echo "$release" | jq -r '.assets[] | select(.name == "revanced-version.txt") | .browser_download_url')
curl -sL -O "$asset"
if diff -q revanced-version.txt new.txt >/dev/null ; then
echo "Old patch!!! Not build"
exit 0
else
rm -f ./*.txt

#################################################

dl_gh "revanced-patches revanced-cli revanced-integrations" "revanced" "latest"

#################################################

# Patch Instagram:
# Arm64-v8a
get_patches_key "instagram"
get_ver "hide-timeline-ads" "com.instagram.android"
#version="275.0.0.27.98"
get_apk "instagram-arm64-v8a" "instagram-instagram" "instagram/instagram-instagram/instagram-instagram" "arm64-v8a"
patch "instagram-arm64-v8a" "instagram-arm64-v8a-revanced"
# Armeabi-v7a
get_patches_key "instagram"
get_ver "hide-timeline-ads" "com.instagram.android"
get_apk "instagram-armeabi-v7a" "instagram-instagram" "instagram/instagram-instagram/instagram-instagram" "armeabi-v7a"
patch "instagram-armeabi-v7a" "instagram-armeabi-v7a-revanced"

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

# Patch YouTube Music:
# Arm64-v8a
get_patches_key "youtube-music-revanced"
get_ver "hide-get-premium" "com.google.android.apps.youtube.music"
get_apk "youtube-music-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
patch "youtube-music-arm64-v8a" "youtube-music-arm64-v8a-revanced"
# Armeabi-v7a
get_ver "hide-get-premium" "com.google.android.apps.youtube.music"
get_patches_key "youtube-music-revanced"
get_apk "youtube-music-armeabi-v7a" "youtube-music" "google-inc/youtube-music/youtube-music" "armeabi-v7a"
patch "youtube-music-armeabi-v7a" "youtube-music-armeabi-v7a-revanced"

#################################################

# Patch YouTube:
get_patches_key "youtube-revanced"
get_ver "video-ads" "com.google.android.youtube"
get_apk "youtube" "youtube" "google-inc/youtube/youtube"
patch "youtube" "youtube-revanced"

#################################################

# Patch Twitter:
get_patches_key "twitter"
version="9.86.0-release.0"
get_apk "twitter" "twitter" "twitter-inc/twitter/twitter"
patch "twitter" "twitter-revanced"

#################################################

# Patch Twitch:
get_patches_key "twitch"
get_ver "block-video-ads" "tv.twitch.android.app"
get_apk "twitch" "twitch" "twitch-interactive-inc/twitch/twitch"
patch "twitch" "twitch-revanced"

#################################################

# Patch Reddit:
get_patches_key "reddit"
get_apk "reddit" "reddit" "redditinc/reddit/reddit"
patch "reddit" "reddit-revanced"

#################################################

# Patch Windy:
get_patches_key "windy"
get_apk "windy" "windy-wind-weather-forecast" "windy-weather-world-inc/windy-wind-weather-forecast/windy-wind-weather-forecast"
patch "windy" "windy-revanced"

#################################################

# Patch Tiktok:
get_patches_key "tiktok"
#version="29.7.4"
get_apk "tiktok" "tik-tok-including-musical-ly" "tiktok-pte-ltd/tik-tok-including-musical-ly/tik-tok-including-musical-ly"
patch "tiktok" "tiktok-revanced"

#################################################

# Split architecture:
rm -f revanced-cli*
dl_gh "revanced-cli" "j-hc" "latest"
# Split architecture Youtube:
for i in {0..3}; do
    split_arch "youtube-revanced" "youtube-${archs[i]}-revanced" "$(gen_rip_libs ${libs[i]})"
done

#################################################

ls revanced-patches*.jar >> revanced-version.txt
fi
