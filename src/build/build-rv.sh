#!/bin/bash
# Revanced build
source src/build/tools.sh

release=$(curl -s "https://api.github.com/repos/revanced/revanced-patches/releases/latest")
asset=$(echo "$release" | jq -r '.assets[] | select(.name | test("revanced-patches.*\\.jar$")) | .browser_download_url')
curl -sL -O "$asset"
ls revanced-patches*.jar >> new.txt
rm -f revanced-patches*.jar
release=$(curl -s "https://api.github.com/repos/FiorenMas/Revanced-And-Revanced-Extended-Non-Root/releases/latest")
asset=$(echo "$release" | jq -r '.assets[] | select(.name == "revanced-version.txt") | .browser_download_url')
curl -sL -O "$asset"
if diff -q revanced-version.txt new.txt >/dev/null ; then
echo "Old patch!!! Not build"
exit 0
else
rm -f *.txt

dl_gh "revanced" 

# Patch Twitter
get_patches_key "twitter"
version="9.86.0-release.0"
get_apk "twitter" "twitter" "twitter-inc/twitter/twitter"
patch "twitter" "twitter-revanced"

# Patch Windy
get_patches_key "windy"
get_apk "windy" "windy-wind-weather-forecast" "windy-weather-world-inc/windy-wind-weather-forecast/windy-wind-weather-forecast"
patch "windy" "windy-revanced"

# Patch Reddit
get_patches_key "reddit"
get_ver "general-reddit-ads" "com.reddit.frontpage"
get_apk "reddit" "reddit" "redditinc/reddit/reddit"
patch "reddit" "reddit-revanced"

# Patch Instagram
get_patches_key "instagram"
version="271.1.0.21.84"
get_apk_arch "instagram" "instagram-instagram" "instagram/instagram-instagram/instagram-instagram"
patch "instagram" "instagram-revanced"

# Patch Messenger
get_patches_key "messenger"
get_apk_arch "messenger" "messenger" "facebook-2/messenger/messenger"
patch "messenger" "messenger-revanced"

# Patch Twitch 
get_patches_key "twitch"
get_ver "block-video-ads" "tv.twitch.android.app"
get_apk "twitch" "twitch" "twitch-interactive-inc/twitch/twitch"
patch "twitch" "twitch-revanced"

# Patch Tiktok 
get_patches_key "tiktok"
get_ver "sim-spoof" "com.ss.android.ugc.trill"
get_apk "tiktok" "tik-tok-including-musical-ly" "tiktok-pte-ltd/tik-tok-including-musical-ly/tik-tok-including-musical-ly"
patch "tiktok" "tiktok-revanced"

# Patch YouTube 
get_patches_key "youtube-revanced"
get_ver "video-ads" "com.google.android.youtube"
get_apk "youtube" "youtube" "google-inc/youtube/youtube"
patch "youtube" "youtube-revanced"

# Patch YouTube Music 
get_patches_key "youtube-music-revanced"
get_ver "hide-get-premium" "com.google.android.apps.youtube.music"
get_apk_arch "youtube-music" "youtube-music" "google-inc/youtube-music/youtube-music"
patch "youtube-music" "youtube-music-revanced"

ls revanced-patches*.jar >> revanced-version.txt
fi
