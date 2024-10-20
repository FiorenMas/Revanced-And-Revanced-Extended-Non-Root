#!/bin/bash
# Revanced build
source ./src/build/utils.sh
# Download requirements
revanced_dl(){
	dl_gh "revanced-patches revanced-cli revanced-integrations" "revanced" "latest"
}
1() {
	revanced_dl
	# Patch YouTube:
	get_patches_key "youtube-revanced"
	get_apk "com.google.android.youtube" "youtube" "youtube" "google-inc/youtube/youtube"
	patch "youtube" "revanced"
	# Patch YouTube Music:
	# Arm64-v8a
	get_patches_key "youtube-music-revanced"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
	patch "youtube-music-arm64-v8a" "revanced"
	# Armeabi-v7a
	get_patches_key "youtube-music-revanced"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-armeabi-v7a" "youtube-music" "google-inc/youtube-music/youtube-music" "armeabi-v7a"
	patch "youtube-music-armeabi-v7a" "revanced"
	# Split architecture:
	rm -f revanced-cli* revanced-patches*.jar *.json 
	dl_gh "revanced-cli" "inotia00" "latest"
	dl_gh "revanced-patches" "inotia00" "latest"
	# Split architecture Youtube:
	for i in {0..3}; do
		split_arch "youtube-revanced" "youtube-${archs[i]}-revanced" "$(gen_rip_libs ${libs[i]})"
	done
}
2() {
	revanced_dl
	# Patch Messenger:
	# Arm64-v8a
	get_patches_key "messenger"
	version="latest"
	get_apk "com.facebook.orca" "messenger-arm64-v8a" "messenger" "facebook-2/messenger/messenger" "arm64-v8a" "nodpi"
	patch "messenger-arm64-v8a" "revanced"
	# Patch Facebook:
	# Arm64-v8a
	get_patches_key "facebook"
 	version="485.0.0.70.77"
	get_apk "com.facebook.katana" "facebook-arm64-v8a" "facebook" "facebook-2/facebook/facebook" "arm64-v8a" "nodpi" "Android 11+"
	patch "facebook-arm64-v8a" "revanced"
}
3() {
	revanced_dl
	# Patch Google photos:
	# Arm64-v8a
	get_patches_key "gg-photos"
	get_apk "com.google.android.apps.photos" "gg-photos-arm64-v8a" "photos" "google-inc/photos/photos" "arm64-v8a" "nodpi"
	patch "gg-photos-arm64-v8a" "revanced"
	# Armeabi-v7a
	get_patches_key "gg-photos"
	version="6.94.0.662644291"
	get_apk "com.google.android.apps.photos" "gg-photos-armeabi-v7a" "photos" "google-inc/photos/photos" "armeabi-v7a" "nodpi"
	patch "gg-photos-armeabi-v7a" "revanced"
}
4() {
	revanced_dl
	# Patch Tiktok:
	get_patches_key "tiktok"
	get_apk "com.zhiliaoapp.musically" "tiktok" "tik-tok-including-musical-ly" "tiktok-pte-ltd/tik-tok-including-musical-ly/tik-tok-including-musical-ly"
	patch "tiktok" "revanced"
	# Patch Instagram:
	# Arm64-v8a
	get_patches_key "instagram"
	get_apk "com.instagram.android" "instagram-arm64-v8a" "instagram-instagram" "instagram/instagram-instagram/instagram-instagram" "arm64-v8a" "nodpi"
	patch "instagram-arm64-v8a" "revanced"
}
5() {
	revanced_dl
	# Patch Pixiv:
	get_patches_key "pixiv"
	get_apk "jp.pxv.android" "pixiv" "pixiv" "pixiv-inc/pixiv/pixiv"
	patch "pixiv" "revanced"
	# Patch Twitch:
	get_patches_key "twitch"
	get_apk "tv.twitch.android.app" "twitch" "twitch" "twitch-interactive-inc/twitch/twitch" "Bundle"
	patch "twitch" "revanced"
}
6() {
	revanced_dl
	# Patch Tumblr:
	get_patches_key "tumblr"
	get_apk "com.tumblr" "tumblr" "tumblr" "tumblr-inc/tumblr/tumblr" "Bundle"
	patch "tumblr" "revanced"
	# Patch SoundCloud:
	get_patches_key "soundcloud"
	get_apk "com.soundcloud.android" "soundcloud" "soundcloud-soundcloud" "soundcloud/soundcloud-soundcloud/soundcloud-soundcloud" "Bundle"
	patch "soundcloud" "revanced"
}
7() {
	revanced_dl
	# Patch RAR:
	get_patches_key "rar"
	get_apk "com.rarlab.rar" "rar" "rar" "rarlab-published-by-win-rar-gmbh/rar/rar" "arm64-v8a"
	patch "rar" "revanced"
	# Patch Lightroom:
	get_patches_key "lightroom"
	get_apk "com.adobe.lrmobile" "lightroom" "lightroom" "adobe/lightroom/lightroom" "Bundle"
	patch "lightroom" "revanced"
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
    7)
        7
        ;;
esac
