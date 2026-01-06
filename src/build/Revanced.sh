#!/bin/bash
# Revanced build
source ./src/build/utils.sh
# Download requirements
revanced_dl(){
	dl_gh "revanced-patches revanced-cli" "revanced" "latest"
}
1() {
	revanced_dl
	# Patch YouTube:
	get_patches_key "youtube-revanced"
	get_apk "com.google.android.youtube" "youtube" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
	split_editor "youtube" "youtube"
	patch "youtube" "revanced"
	# Patch Youtube Arm64-v8a
	get_patches_key "youtube-revanced" 
	split_editor "youtube" "youtube-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "youtube-arm64-v8a" "revanced"
	# Patch Youtube Armeabi-v7a
	get_patches_key "youtube-revanced" 
	split_editor "youtube" "youtube-armeabi-v7a" "exclude" "split_config.arm64_v8a split_config.x86 split_config.x86_64"
	patch "youtube-armeabi-v7a" "revanced"
	# Patch Youtube x86
	get_patches_key "youtube-revanced" 
	split_editor "youtube" "youtube-x86" "exclude" "split_config.arm64_v8a split_config.armeabi_v7a split_config.x86_64"
	patch "youtube-x86" "revanced"
	# Patch Youtube x86_64
	get_patches_key "youtube-revanced" 
	split_editor "youtube" "youtube-x86_64" "exclude" "split_config.arm64_v8a split_config.armeabi_v7a split_config.x86"
	patch "youtube-x86_64" "revanced"
}
2() {
	revanced_dl
	# Patch Messenger:
	# Arm64-v8a
	get_patches_key "messenger"
	url="https://facebook-messenger.en.uptodown.com/android/download"
	url="https://dw.uptodown.com/dwn/$(req "$url" - | $pup -p --charset utf-8 'button#detail-download-button attr{data-url}')"
	req "$url" "messenger-arm64-v8a.apk"
	patch "messenger-arm64-v8a" "revanced"
	# Patch Facebook:
	# Arm64-v8a
	get_patches_key "facebook"
	url="https://d.apkpure.com/b/APK/com.facebook.katana?versionCode=457020009"
	req "$url" "facebook-arm64-v8a.apk"
	patch "facebook-arm64-v8a" "revanced"
}
3() {
	revanced_dl
	# Patch Google photos:
	# Arm64-v8a
	get_patches_key "gg-photos"
	get_apk "com.google.android.apps.photos" "gg-photos-arm64-v8a" "photos" "google-inc/photos/google-photos" "arm64-v8a" "nodpi"
	patch "gg-photos-arm64-v8a" "revanced"
	# Armeabi-v7a
	#get_patches_key "gg-photos"
 	#version="7.32.0.765953717"
	#get_apk "com.google.android.apps.photos" "gg-photos-armeabi-v7a" "photos" "google-inc/photos/google-photos" "armeabi-v7a" "nodpi"
	#patch "gg-photos-armeabi-v7a" "revanced"
	# x86
	#get_patches_key "gg-photos"
 	#version="7.32.0.765953717"
	#get_apk "com.google.android.apps.photos" "gg-photos-x86" "photos" "google-inc/photos/google-photos" "x86" "nodpi"
	#patch "gg-photos-x86" "revanced"
	# x86_64
	#get_patches_key "gg-photos"
 	#version="7.32.0.765953717"
	#get_apk "com.google.android.apps.photos" "gg-photos-x86_64" "photos" "google-inc/photos/google-photos" "x86_64" "nodpi"
	#patch "gg-photos-x86_64" "revanced"
}
4() {
	revanced_dl
	# Patch Tiktok:
	get_patches_key "tiktok"
	url="https://tiktok.en.uptodown.com/android/download/1026195874-x" #Use uptodown because apkmirror ban tiktok in US lead github action can't download apk file
	url="https://dw.uptodown.com/dwn/$(req "$url" - | $pup -p --charset utf-8 'button#detail-download-button attr{data-url}')"
	req "$url" "tiktok.apk"
	patch "tiktok" "revanced"
	# Patch Instagram:
	# Arm64-v8a
	get_patches_key "instagram"
 	get_apkpure "com.instagram.android" "instagram-arm64-v8a" "instagram-android/com.instagram.android" "Bundle"
	patch "instagram-arm64-v8a" "revanced"
}
5() {
	revanced_dl
	# Patch Pixiv:
	get_patches_key "pixiv"
	get_apkpure "jp.pxv.android" "pixiv" "pixiv/jp.pxv.android"
	patch "pixiv" "revanced"
	# Patch Twitch:
	get_patches_key "twitch"
	get_apk "tv.twitch.android.app" "twitch" "twitch" "twitch-interactive-inc/twitch/twitch-live-streaming" "Bundle_extract"
	split_editor "twitch" "twitch"
	patch "twitch" "revanced"
	# Patch Twitch Arm64-v8a:
	get_patches_key "twitch"
	split_editor "twitch" "twitch-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "twitch-arm64-v8a" "revanced"
}
6() {
	revanced_dl
	# Patch Tumblr:
	get_patches_key "tumblr"
	get_apk "com.tumblr" "tumblr" "tumblr" "tumblr-inc/tumblr/tumblr-social-media-art" "Bundle_extract"
	split_editor "tumblr" "tumblr"
	patch "tumblr" "revanced"
	# Patch Tumblr Arm64-v8a:
	get_patches_key "tumblr"
	split_editor "tumblr" "tumblr-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "tumblr-arm64-v8a" "revanced"
	# Patch SoundCloud:
	get_patches_key "soundcloud"
	get_apk "com.soundcloud.android" "soundcloud" "soundcloud-soundcloud" "soundcloud/soundcloud-soundcloud/soundcloud-play-music-songs" "Bundle_extract"
	split_editor "soundcloud" "soundcloud"
	patch "soundcloud" "revanced"
	# Patch SoundCloud Arm64-v8a:
	get_patches_key "soundcloud"
	split_editor "soundcloud" "soundcloud-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "soundcloud-arm64-v8a" "revanced"
}
7() {
	revanced_dl
	# Patch RAR:
	get_patches_key "rar"
	get_apk "com.rarlab.rar" "rar" "rar" "rarlab-published-by-win-rar-gmbh/rar/rar" "Bundle"
	patch "rar" "revanced"
	# Patch Lightroom:
	get_patches_key "lightroom"
 	url="https://adobe-lightroom-mobile.en.uptodown.com/android/download/1033600808" #Use uptodown because apkmirror always ask pass Cloudflare on this app
	url="https://dw.uptodown.com/dwn/$(req "$url" - | $pup -p --charset utf-8 'button#detail-download-button attr{data-url}')"
	req "$url" "lightroom.apk"
	patch "lightroom" "revanced"
}
8() {
	revanced_dl
	get_apk "com.google.android.youtube" "youtube-lite" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
	# Patch YouTube Lite Arm64-v8a:
	get_patches_key "youtube-revanced"
	split_editor "youtube-lite" "youtube-lite-arm64-v8a" "include" "split_config.arm64_v8a split_config.en split_config.xxxhdpi"
	patch "youtube-lite-arm64-v8a" "revanced"
	# Patch YouTube Lite Armeabi-v7a:
	get_patches_key "youtube-revanced"
	split_editor "youtube-lite" "youtube-lite-armeabi-v7a" "include" "split_config.armeabi_v7a split_config.en split_config.xxxhdpi"
	patch "youtube-lite-armeabi-v7a" "revanced"
}
9() {
	revanced_dl
	# Patch YouTube Music:
	# Arm64-v8a
	get_patches_key "youtube-music-revanced"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
	patch "youtube-music-arm64-v8a" "revanced"
	# Armeabi-v7a
	get_patches_key "youtube-music-revanced"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-armeabi-v7a" "youtube-music" "google-inc/youtube-music/youtube-music" "armeabi-v7a"
	patch "youtube-music-armeabi-v7a" "revanced"
	# x86_64
	get_patches_key "youtube-music-revanced"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-x86_64" "youtube-music" "google-inc/youtube-music/youtube-music" "x86_64"
	patch "youtube-music-x86_64" "revanced"
	# x86
	get_patches_key "youtube-music-revanced"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-x86" "youtube-music" "google-inc/youtube-music/youtube-music" "x86"
	patch "youtube-music-x86" "revanced"
}
10() {
	revanced_dl
	# Patch Duolingo
	get_patches_key "Duolingo"
	lock_version="1"
	get_apk "com.duolingo" "duolingo" "duolingo-duolingo" "duolingo/duolingo-duolingo/duolingo-language-lessons" "Bundle"
	patch "duolingo" "revanced"
	# Patch Google News Arm64-v8a
	get_patches_key "GoogleNews"
	get_apk "com.google.android.apps.magazines" "googlenews" "google-news" "google-inc/google-news/google-news" "Bundle_extract"
	split_editor "googlenews" "googlenews-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "googlenews-arm64-v8a" "revanced"
}
11() {
	revanced_dl
	# Patch Photomath
	get_patches_key "Photomath"
	get_apk "com.microblink.photomath" "photomath" "photomath" "google-inc/photomath/photomath" "Bundle" "Bundle_extract"
	split_editor "photomath" "photomath"
	patch "photomath" "revanced"
	# Patch Strava:
	get_patches_key "strava"
	get_apkpure "com.strava" "strava-arm64-v8a" "strava-run-hike-2025-health/com.strava" "Bundle"
	patch "strava-arm64-v8a" "revanced"
}
12() {
	revanced_dl
	# Patch Spotjfy Arm64-v8a
	j="i"
	get_patches_key "Spotjfy-revanced"
	get_apkpure "com.spot"$j"fy.music" "spotjfy-arm64-v8a" "spot"$j"fy-music-and-podcasts-for-android/com.spot"$j"fy.music"
	patch "spotjfy-arm64-v8a" "revanced"
	# Patch Proton mail
	get_patches_key "protonmail-revanced"
	get_apk "ch.protonmail.android" "protonmail" "protonmail-encrypted-email" "proton-technologies-ag/protonmail-encrypted-email/proton-mail-encrypted-email"
	patch "protonmail" "revanced"
}
13() {
	revanced_dl
	# Patch Threads
	get_patches_key "Threads-revanced"
	get_apkpure "com.instagram.barcelona" "threads-arm64-v8a" "threads/com.instagram.barcelona" "Bundle"
	patch "threads-arm64-v8a" "revanced"
	# Patch Prime Video
	get_patches_key "Prime-Video-revanced"
	version="3.0.412"
	get_apk " com.amazon.avod.thirdpartyclient" "prime-video-arm64-v8a" "amazon-prime-video" "amazon-mobile-llc/amazon-prime-video/amazon-prime-video" "arm64-v8a"
	patch "prime-video-arm64-v8a" "revanced"
}
14() {
	revanced_dl
	# Patch Crunchyroll
	get_patches_key "Crunchyroll-revanced"
	url="https://crunchyroll.en.uptodown.com/android/download/1133091557-x" #Use uptodown because apkmirror always ask pass Cloudflare on this app
	url="https://dw.uptodown.com/dwn/$(req "$url" - | $pup -p --charset utf-8 'button#detail-download-button attr{data-url}')"
	req "$url" "crunchyroll"
	split_editor "crunchyroll" "crunchyroll"
	patch "crunchyroll" "revanced"
	# Patch Viber
	get_patches_key "Viber-revanced"
	get_apk "com.viber.voip" "viber" "viber" "viber-media-s-a-r-l/viber/rakuten-viber-messenger"
	patch "viber" "revanced"
}
15() {
	revanced_dl
	# Patch Reddit
	get_patches_key "reddit"
	get_apk "com.reddit.frontpage" "reddit" "reddit" "redditinc/reddit/reddit" "Bundle_extract"
	split_editor "reddit" "reddit"
	patch "reddit" "revanced"
	# Patch Arm64-v8a:
	split_editor "reddit" "reddit-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86_64 split_config.mdpi split_config.ldpi split_config.hdpi split_config.xhdpi split_config.xxhdpi split_config.tvdpi"
	get_patches_key "reddit"
	patch "reddit-arm64-v8a" "revanced"
	# Patch Disney+
	get_patches_key "Disney"
	version="4.20.2+rc1-2025.12.09"
	get_apk "com.disney.disneyplus" "disney" "disney" "disney/disney/disney" "Bundle"
	patch "disney" "revanced"
}
16() {
	revanced_dl
	# Patch ProtonVPN
	get_patches_key "ProtonVPN"
	get_apk "ch.protonvpn.android" "protonvpn" "protonvpn-free-vpn-secure-unlimited-fdroid-version" "proton-technologies-ag/protonvpn-free-vpn-secure-unlimited-fdroid-version/protonvpn-fast-secure-vpn-f-droid-version"
	patch "protonvpn" "revanced"
	# Patch MyFitnessPal
	get_patches_key "MyFitnessPal"
 	url="https://calorie-counter-myfitnesspal.en.uptodown.com/android/download/1010004885" #Use uptodown because apkmirror always ask pass Cloudflare on this app
	url="https://dw.uptodown.com/dwn/$(req "$url" - | $pup -p --charset utf-8 'button#detail-download-button attr{data-url}')"
	req "$url" "MyFitnessPal.apk"
	patch "MyFitnessPal" "revanced"
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
    11)
        11
        ;;
    12)
        12
        ;;
    13)
        13
        ;;
    14)
        14
        ;;
    15)
        15
        ;;
    16)
        16
        ;;
esac
