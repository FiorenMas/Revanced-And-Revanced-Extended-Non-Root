#!/bin/bash
# Revanced build
source src/build/tools.sh

curl -sL -O $(curl -s "https://api.github.com/repos/revanced/revanced-patches/releases/latest" | jq -r '.assets[] | select(.name | test("revanced-patches.*\\.jar$")) | .browser_download_url')
ls revanced-patches*.jar >> new.txt
curl -sL -O $(curl -s "https://api.github.com/repos/$repository/releases/latest" | jq -r '.assets[] | select(.name == "revanced-version.txt") | .browser_download_url')
if diff -q revanced-version.txt new.txt >/dev/null ; then
rm -f ./revanced-patches*.jar ./*.txt
echo "Old patch!!! Not build"
exit 0
else

dl_gh "revanced-patches revanced-cli revanced-integrations" "revanced" "latest"

# Patch YouTube 
get_patches_key "youtube-revanced"
get_ver "video-ads" "com.google.android.youtube"
get_apk "youtube" "youtube" "google-inc/youtube/youtube"
patch "youtube" "youtube-revanced"

# Patch Instagram
get_patches_key "instagram"
version="271.1.0.21.84"
get_apk_arch "instagram" "instagram-instagram" "instagram/instagram-instagram/instagram-instagram"
patch "instagram" "instagram-revanced"

# Patch Messenger
get_patches_key "messenger"
get_apk_arch "messenger" "messenger" "facebook-2/messenger/messenger"
patch "messenger" "messenger-revanced"

# Patch Windy
get_patches_key "windy"
get_apk "windy" "windy-wind-weather-forecast" "windy-weather-world-inc/windy-wind-weather-forecast/windy-wind-weather-forecast"
patch "windy" "windy-revanced"

# Patch Reddit
get_patches_key "reddit"
get_ver "general-reddit-ads" "com.reddit.frontpage"
get_apk "reddit" "reddit" "redditinc/reddit/reddit"
patch "reddit" "reddit-revanced"

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

# Patch YouTube Music 
get_patches_key "youtube-music-revanced"
get_ver "hide-get-premium" "com.google.android.apps.youtube.music"
get_apk_arch "youtube-music" "youtube-music" "google-inc/youtube-music/youtube-music"
patch "youtube-music" "youtube-music-revanced"

# Patch Twitter
rm -f ./revanced-integrations*.apk
dl_gh "revanced-integrations" "revanced" "tags/v0.103.0"
get_patches_key "twitter"
version="9.86.0-release.0"
get_apk "twitter" "twitter" "twitter-inc/twitter/twitter"
patch "twitter" "twitter-revanced"

# Change architecture
rm -f ./revanced-cli*
dl_gh "revanced-cli" "j-hc" "latest"
for i in {0..3}; do
	change_arch "youtube-revanced" "youtube-revanced-${archs[i]}" "$(gen_rip_libs ${libs[i]})"
done

ls revanced-patches*.jar >> revanced-version.txt
fi