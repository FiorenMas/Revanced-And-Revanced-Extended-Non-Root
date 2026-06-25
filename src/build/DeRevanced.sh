#!/bin/bash
# DeRevanced build
source ./src/build/utils.sh
# Download requirements
derevanced_dl(){
	dl_gh "morphe-cli" "MorpheApp" "latest"
	dl_gh "De-ReVanced" "RookieEnough" "latest"
}
1() {
	derevanced_dl
	# Patch Google photos:
	# Arm64-v8a
	get_patches_key "gg-photos-derevanced"
	get_apk "com.google.android.apps.photos" "gg-photos-arm64-v8a" "bundle" "arm64-v8a" "320-640dpi" "Android 12L+"
	patch "gg-photos-arm64-v8a" "derevanced" "morphe"
	# Patch Tiktok:
	get_patches_key "tiktok-derevanced"
	get_apk "com.zhiliaoapp.musically" "tiktok" "apk" "arm64-v8a + armeabi-v7a" "nodpi"
	patch "tiktok" "derevanced" "morphe"
}
2() {
	derevanced_dl
	# Patch Messenger:
	# Arm64-v8a
	get_patches_key "messenger-derevanced"
	version="552.0.0.44.65"
	get_apk "com.facebook.orca" "messenger-arm64-v8a" "apk" "arm64-v8a" "nodpi" "Android 9.0+"
	patch "messenger-arm64-v8a" "derevanced" "morphe"
	# Patch Facebook:
	# Arm64-v8a
	get_patches_key "facebook-derevanced"
	get_apk "com.facebook.katana" "facebook-arm64-v8a" "bundle" "arm64-v8a" "nodpi" "Android 11+"
	patch "facebook-arm64-v8a" "derevanced" "morphe"
}
3() {
	derevanced_dl
	# Patch Pixiv:
	get_patches_key "pixiv-derevanced"
	get_apk "jp.pxv.android" "pixiv" "apk"
	patch "pixiv" "derevanced" "morphe"
	# Patch Twitch:
	get_patches_key "twitch-derevanced"
	get_apk "tv.twitch.android.app" "twitch" "bundle_extract"
	split_editor "twitch" "twitch"
	patch "twitch" "derevanced" "morphe"
	# Patch Twitch Arm64-v8a:
	get_patches_key "twitch-derevanced"
	split_editor "twitch" "twitch-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "twitch-arm64-v8a" "derevanced" "morphe"
}
4() {
	derevanced_dl
	# Patch Tumblr:
	get_patches_key "tumblr-derevanced"
	get_apk "com.tumblr" "tumblr" "bundle_extract"
	split_editor "tumblr" "tumblr"
	patch "tumblr" "derevanced" "morphe"
	# Patch Tumblr Arm64-v8a:
	get_patches_key "tumblr-derevanced"
	split_editor "tumblr" "tumblr-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "tumblr-arm64-v8a" "derevanced" "morphe"
	# Patch SoundCloud:
	get_patches_key "soundcloud-derevanced"
	get_apk "com.soundcloud.android" "soundcloud" "bundle_extract"
	split_editor "soundcloud" "soundcloud"
	patch "soundcloud" "derevanced" "morphe"
	# Patch SoundCloud Arm64-v8a:
	get_patches_key "soundcloud-derevanced"
	split_editor "soundcloud" "soundcloud-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "soundcloud-arm64-v8a" "derevanced" "morphe"
}
5() {
	derevanced_dl
	# Patch RAR:
	get_patches_key "rar-derevanced"
	get_apk "com.rarlab.rar" "rar" "bundle" "universal" "120-640dpi" "Android 5.0+" 
	patch "rar" "derevanced" "morphe"
	# Patch Google News Arm64-v8a
	#get_patches_key "GoogleNews-derevanced"
	#get_apk "com.google.android.apps.magazines" "googlenews" "bundle_extract"
	#split_editor "googlenews" "googlenews-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	#patch "googlenews-arm64-v8a" "derevanced" "morphe"
}
6() {
	derevanced_dl
	# Patch Photomath
	get_patches_key "Photomath-derevanced"
	get_apk "com.microblink.photomath" "photomath" "bundle_extract"
	split_editor "photomath" "photomath"
	patch "photomath" "derevanced" "morphe"
	# Patch Strava:
	#get_patches_key "strava-derevanced"
	#get_apk_chplay "com.strava" "strava-arm64-v8a"
	#patch "strava-arm64-v8a" "derevanced" "morphe"
}
7() {
	derevanced_dl
	# Patch Proton mail
	get_patches_key "protonmail-derevanced"
	get_apk "ch.protonmail.android" "protonmail" "apk"
	patch "protonmail" "derevanced" "morphe"
	# Patch Threads
	get_patches_key "Threads-derevanced"
	get_apk "com.instagram.barcelona" "threads-arm64-v8a" "bundle" "arm64-v8a" "120-640dpi" "Android 9.0+" 
	patch "threads-arm64-v8a" "derevanced" "morphe"
}
8() {
	derevanced_dl
	# Patch Viber
	get_patches_key "Viber-derevanced"
	get_apk "com.viber.voip" "viber" "apk"
	patch "viber" "derevanced" "morphe"
}
9() {
	derevanced_dl
	# Google Recorder
	get_patches_key "google-recorder-derevanced"
	get_apk "com.google.android.apps.recordero" "google-recorder" "bundle"
	patch "google-recorder" "derevanced" "morphe"
}
10() {
	derevanced_dl

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
    8)
        8
        ;;
    9)
        9
        ;;
    10)
        10
        ;;
esac
