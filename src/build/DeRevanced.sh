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
	get_apk "com.google.android.apps.photos" "gg-photos-arm64-v8a" "photos" "google-inc/photos/google-photos" "arm64-v8a" "nodpi"
	patch "gg-photos-arm64-v8a" "derevanced" "morphe"
	# Patch Tiktok:
	get_patches_key "tiktok-derevanced"
	url="https://tiktok.en.uptodown.com/android/download/1142278864-x" #Use uptodown because apkmirror ban tiktok in US lead github action can't download apk file
	url="https://dw.uptodown.com/dwn/$(req "$url" - | $pup -p --charset utf-8 'button#detail-download-button attr{data-url}')"
	req "$url" "tiktok.apk"
	patch "tiktok" "derevanced" "morphe"
}
2() {
	derevanced_dl
	# Patch Messenger:
	# Arm64-v8a
	get_patches_key "messenger-derevanced"
	version="552.0.0.44.65"
	get_apkpure "com.facebook.orca" "messenger-arm64-v8a" "facebook-messenger/com.facebook.orca"
	patch "messenger-arm64-v8a" "derevanced" "morphe"
	# Patch Facebook:
	# Arm64-v8a
	get_patches_key "facebook-derevanced"
	url="https://d.apkpure.com/b/APK/com.facebook.katana?versionCode=457020014"
	req "$url" "facebook-arm64-v8a.apk"
	patch "facebook-arm64-v8a" "derevanced" "morphe"
}
3() {
	derevanced_dl
	# Patch Pixiv:
	get_patches_key "pixiv-derevanced"
	get_apkpure "jp.pxv.android" "pixiv" "pixiv/jp.pxv.android"
	patch "pixiv" "derevanced" "morphe"
	# Patch Twitch:
	get_patches_key "twitch-derevanced"
	get_apk "tv.twitch.android.app" "twitch" "twitch" "twitch-interactive-inc/twitch/twitch-live-streaming" "Bundle_extract"
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
	get_apk "com.tumblr" "tumblr" "tumblr" "tumblr-inc/tumblr/tumblr-social-media-art-blog" "Bundle_extract"
	split_editor "tumblr" "tumblr"
	patch "tumblr" "derevanced" "morphe"
	# Patch Tumblr Arm64-v8a:
	get_patches_key "tumblr-derevanced"
	split_editor "tumblr" "tumblr-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "tumblr-arm64-v8a" "derevanced" "morphe"
	# Patch SoundCloud:
	get_patches_key "soundcloud-derevanced"
	get_apk "com.soundcloud.android" "soundcloud" "soundcloud-soundcloud" "soundcloud/soundcloud-soundcloud/soundcloud-play-music-songs" "Bundle_extract"
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
	get_apk "com.rarlab.rar" "rar" "rar" "rarlab-published-by-win-rar-gmbh/rar/rar" "Bundle"
	patch "rar" "derevanced" "morphe"
	# Patch Google News Arm64-v8a
	get_patches_key "GoogleNews-derevanced"
	get_apk "com.google.android.apps.magazines" "googlenews" "google-news" "google-inc/google-news/google-news" "Bundle_extract"
	split_editor "googlenews" "googlenews-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "googlenews-arm64-v8a" "derevanced" "morphe"
}
6() {
	derevanced_dl
	# Patch Photomath
	get_patches_key "Photomath-derevanced"
	get_apk "com.microblink.photomath" "photomath" "photomath" "google-inc/photomath/photomath" "Bundle" "Bundle_extract"
	split_editor "photomath" "photomath"
	patch "photomath" "derevanced" "morphe"
	# Patch Strava:
	get_patches_key "strava-derevanced"
	get_apkpure "com.strava" "strava-arm64-v8a" "strava-run-hike-android-exercise-laugh/com.strava" "Bundle"
	patch "strava-arm64-v8a" "derevanced" "morphe"
}
7() {
	derevanced_dl
	# Patch Proton mail
	get_patches_key "protonmail-derevanced"
	get_apk "ch.protonmail.android" "protonmail" "protonmail-encrypted-email" "proton-technologies-ag/protonmail-encrypted-email/proton-mail-encrypted-email"
	patch "protonmail" "derevanced" "morphe"
	# Patch Threads
	get_patches_key "Threads-derevanced"
	get_apkpure "com.instagram.barcelona" "threads-arm64-v8a" "threads/com.instagram.barcelona" "Bundle"
	patch "threads-arm64-v8a" "derevanced" "morphe"
}
8() {
	derevanced_dl
	# Patch Viber
	get_patches_key "Viber-derevanced"
	get_apk "com.viber.voip" "viber" "viber" "viber-media-s-a-r-l/viber/rakuten-viber-messenger"
	patch "viber" "derevanced" "morphe"
}
9() {
	derevanced_dl
	# Google Recorder
	get_patches_key "google-recorder-derevanced"
	get_apk "com.google.android.apps.recordero" "google-recorder" "google-recorder" "google-inc/google-recorder/google-recorder" "Bundle"
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
