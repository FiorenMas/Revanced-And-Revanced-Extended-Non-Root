#!/bin/bash
# Reseam build
source ./src/build/utils.sh
# Download requirements
Reseam_dl(){
	dl_gh "patches" "Reseam" "latest"
	dl_gh "reseam" "Reseam" "latest"
}
1() {
	Reseam_dl
	# Patch YouTube:
	get_patches_key "youtube-reseam"
	get_apk "com.google.android.youtube" "youtube" "apk"
	patch "youtube" "reseam"
	# Remove unused architectures
	for i in {0..3}; do
		split_arch "youtube" "reseam"
	done
	# Patch YouTube Music:
	# Arm64-v8a
	get_patches_key "youtube-music-reseam"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-arm64-v8a" "apk" "arm64-v8a"
	patch "youtube-music-arm64-v8a" "reseam"
}
2() {
	Reseam_dl
	# Patch Reddit:
	get_patches_key "reddit-reseam"
	get_apk "com.reddit.frontpage" "reddit" "bundle_extract"
	split_editor "reddit" "reddit"
	patch "reddit" "reseam"
	# Patch Reddit Arm64-v8a:
	get_patches_key "reddit-reseam"
	split_editor "reddit" "reddit-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86_64 split_config.mdpi split_config.ldpi split_config.hdpi split_config.xhdpi split_config.xxhdpi split_config.tvdpi"
	patch "reddit-arm64-v8a" "reseam"
	# Patch Twitter:
	get_patches_key "twitter-reseam"
	get_apk "com.twitter.android" "twitter" "bundle"
	patch "twitter" "reseam"
}
3() {
	Reseam_dl
	# Patch TikTok:
	get_patches_key "tiktok-reseam"
	get_apk "com.zhiliaoapp.musically" "tiktok" "apk" "arm64-v8a + armeabi-v7a" "nodpi"
	patch "tiktok" "reseam"
	# Patch Instagram:
	# Arm64-v8a
	get_patches_key "instagram-reseam"
	get_apk "com.instagram.android" "instagram-arm64-v8a" "bundle" "arm64-v8a" "120-640dpi" "Android 9.0+"
	patch "instagram-arm64-v8a" "reseam"
}
4() {
	Reseam_dl
	# Patch Twitch:
	get_patches_key "twitch-reseam"
	get_apk "tv.twitch.android.app" "twitch" "bundle_extract"
	split_editor "twitch" "twitch"
	patch "twitch" "reseam"
	# Patch Twitch Arm64-v8a:
	get_patches_key "twitch-reseam"
	split_editor "twitch" "twitch-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "twitch-arm64-v8a" "reseam"
	# Patch Discord:
	get_patches_key "discord-reseam"
	get_apk "com.discord" "discord" "bundle"
	patch "discord" "reseam"
}
5() {
	Reseam_dl
	# Patch Pinterest:
	get_patches_key "pinterest-reseam"
	get_apk "com.pinterest" "pinterest" "apk"
	patch "pinterest" "reseam"
	# Patch Threads:
	# Arm64-v8a
	get_patches_key "threads-reseam"
	get_apk "com.instagram.barcelona" "threads-arm64-v8a" "bundle" "arm64-v8a" "160-640dpi" "Android 9.0+"
	patch "threads-arm64-v8a" "reseam"
}
6() {
	Reseam_dl
	# Patch Telegram:
	get_patches_key "telegram-reseam"
	get_apk "org.telegram.messenger" "telegram" "apk"
	patch "telegram" "reseam"
}
case "$1" in
    1)
        1
        ;;
    2)
        2
        ;;
    3)
        3
        ;;
    4)
        4
        ;;
    5)
        5
        ;;
    6)
        6
        ;;
esac
