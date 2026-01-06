#!/bin/bash
# Revanced build
source ./src/build/utils.sh
# Download requirements
revanced_dl(){
	dl_gh "revanced-patches" "revanced" "prerelease"
 	dl_gh "revanced-cli" "revanced" "latest"
}
1() {
	revanced_dl
	# Patch YouTube:
	get_patches_key "youtube-revanced"
	get_apk "com.google.android.youtube" "youtube-beta" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
	split_editor "youtube-beta" "youtube-beta"
	patch "youtube-beta" "revanced"
	# Patch Youtube Arm64-v8a
	get_patches_key "youtube-revanced" 
	split_editor "youtube-beta" "youtube-beta-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "youtube-beta-arm64-v8a" "revanced"
	# Patch Youtube Armeabi-v7a
	get_patches_key "youtube-revanced" 
	split_editor "youtube-beta" "youtube-beta-armeabi-v7a" "exclude" "split_config.arm64_v8a split_config.x86 split_config.x86_64"
	patch "youtube-beta-armeabi-v7a" "revanced"
	# Patch Youtube x86
	get_patches_key "youtube-revanced" 
	split_editor "youtube-beta" "youtube-beta-x86" "exclude" "split_config.arm64_v8a split_config.armeabi_v7a split_config.x86_64"
	patch "youtube-beta-x86" "revanced"
	# Patch Youtube x86_64
	get_patches_key "youtube-revanced" 
	split_editor "youtube-beta" "youtube-beta-x86_64" "exclude" "split_config.arm64_v8a split_config.armeabi_v7a split_config.x86"
	patch "youtube-beta-x86_64" "revanced"
}
2() {
	revanced_dl
	# Patch Messenger:
	# Arm64-v8a
	get_patches_key "messenger"
	url="https://facebook-messenger.en.uptodown.com/android/download"
	url="https://dw.uptodown.com/dwn/$(req "$url" - | $pup -p --charset utf-8 'button#detail-download-button attr{data-url}')"
	req "$url" "messenger-arm64-v8a-beta.apk"
	patch "messenger-arm64-v8a-beta" "revanced"
	# Patch Facebook:
	# Arm64-v8a
	get_patches_key "facebook"
	url="https://d.apkpure.com/b/APK/com.facebook.katana?versionCode=457020009"
	req "$url" "facebook-arm64-v8a-beta.apk"
	patch "facebook-arm64-v8a-beta" "revanced"
}
3() {
	revanced_dl
	# Patch Google photos:
	# Arm64-v8a
	get_patches_key "gg-photos"
	get_apk "com.google.android.apps.photos" "gg-photos-arm64-v8a-beta" "photos" "google-inc/photos/google-photos" "arm64-v8a" "nodpi"
	patch "gg-photos-arm64-v8a-beta" "revanced"
	# Armeabi-v7a
	#get_patches_key "gg-photos"
	#get_apk "com.google.android.apps.photos" "gg-photos-armeabi-v7a-beta" "photos" "google-inc/photos/google-photos" "armeabi-v7a" "nodpi"
	#patch "gg-photos-armeabi-v7a-beta" "revanced"
	# x86
	#get_patches_key "gg-photos"
	#get_apk "com.google.android.apps.photos" "gg-photos-x86-beta" "photos" "google-inc/photos/google-photos" "x86" "nodpi"
	#patch "gg-photos-x86-beta" "revanced"
	# x86_64
	#get_patches_key "gg-photos"
	#get_apk "com.google.android.apps.photos" "gg-photos-x86_64-beta" "photos" "google-inc/photos/google-photos" "x86_64" "nodpi"
	#patch "gg-photos-x86_64-beta" "revanced"
}
4() {
	revanced_dl
	# Patch Tiktok:
	get_patches_key "tiktok"
	url="https://tiktok.en.uptodown.com/android/download/1026195874-x" #Use uptodown because apkmirror ban tiktok in US lead github action can't download apk file
	url="https://dw.uptodown.com/dwn/$(req "$url" - | $pup -p --charset utf-8 'button#detail-download-button attr{data-url}')"
	req "$url" "tiktok-beta.apk"
	patch "tiktok-beta" "revanced"
	# Patch Instagram:
	# Arm64-v8a
	get_patches_key "instagram"
	get_apkpure "com.instagram.android" "instagram-arm64-v8a-beta" "instagram-android/com.instagram.android" "Bundle"
	patch "instagram-arm64-v8a-beta" "revanced"
}
5() {
	revanced_dl
	# Patch Pixiv:
	get_patches_key "pixiv"
	get_apkpure "jp.pxv.android" "pixiv-beta" "pixiv/jp.pxv.android"
	patch "pixiv-beta" "revanced"
	# Patch Twitch:
	get_patches_key "twitch"
	get_apk "tv.twitch.android.app" "twitch-beta" "twitch" "twitch-interactive-inc/twitch/twitch-live-streaming" "Bundle_extract"
 	split_editor "twitch-beta" "twitch-beta"
	patch "twitch-beta" "revanced"
	# Patch Twitch Arm64-v8a:
	get_patches_key "twitch"
	split_editor "twitch-beta" "twitch-arm64-v8a-beta" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "twitch-arm64-v8a-beta" "revanced"
}
6() {
	revanced_dl
	# Patch Tumblr:
	get_patches_key "tumblr"
	get_apk "com.tumblr" "tumblr-beta" "tumblr" "tumblr-inc/tumblr/tumblr-social-media-art" "Bundle_extract"
	split_editor "tumblr-beta" "tumblr-beta"
	patch "tumblr-beta" "revanced"
	# Patch Tumblr Arm64-v8a:
	get_patches_key "tumblr"
	split_editor "tumblr-beta" "tumblr-arm64-v8a-beta" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "tumblr-arm64-v8a-beta" "revanced"
	# Patch SoundCloud:
	get_patches_key "soundcloud"
	get_apk "com.soundcloud.android" "soundcloud-beta" "soundcloud-soundcloud" "soundcloud/soundcloud-soundcloud/soundcloud-play-music-songs" "Bundle_extract"
	split_editor "soundcloud-beta" "soundcloud-beta"
	patch "soundcloud-beta" "revanced"
	# Patch SoundCloud Arm64-v8a:
	get_patches_key "soundcloud"
	split_editor "soundcloud-beta" "soundcloud-arm64-v8a-beta" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "soundcloud-arm64-v8a-beta" "revanced"
}
7() {
	revanced_dl
	# Patch Lightroom:
	get_patches_key "lightroom"
 	url="https://adobe-lightroom-mobile.en.uptodown.com/android/download/1033600808" #Use uptodown because apkmirror always ask pass Cloudflare on this app
	url="https://dw.uptodown.com/dwn/$(req "$url" - | $pup -p --charset utf-8 'button#detail-download-button attr{data-url}')"
	req "$url" "lightroom-beta.apk"
	patch "lightroom-beta" "revanced"
	# Patch RAR:
	get_patches_key "rar"
	get_apk "com.rarlab.rar" "rar-beta" "rar" "rarlab-published-by-win-rar-gmbh/rar/rar" "Bundle"
	patch "rar-beta" "revanced"
}
8() {
	revanced_dl
	get_apk "com.google.android.youtube" "youtube-lite-beta" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
	# Patch YouTube Lite Arm64-v8a:
	get_patches_key "youtube-revanced"
	split_editor "youtube-lite-beta" "youtube-lite-beta-arm64-v8a" "include" "split_config.arm64_v8a split_config.en split_config.xxxhdpi"
	patch "youtube-lite-beta-arm64-v8a" "revanced"
	# Patch YouTube Lite Armeabi-v7a:
	get_patches_key "youtube-revanced"
	split_editor "youtube-lite-beta" "youtube-lite-beta-armeabi-v7a" "include" "split_config.armeabi_v7a split_config.en split_config.xxxhdpi"
	patch "youtube-lite-beta-armeabi-v7a" "revanced"
}
9() {
	revanced_dl
	# Patch YouTube Music:
	# Arm64-v8a
	get_patches_key "youtube-music-revanced"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-beta-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
	patch "youtube-music-beta-arm64-v8a" "revanced"
	# Armeabi-v7a
	get_patches_key "youtube-music-revanced"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-beta-armeabi-v7a" "youtube-music" "google-inc/youtube-music/youtube-music" "armeabi-v7a"
	patch "youtube-music-beta-armeabi-v7a" "revanced"
	# x86_64
	get_patches_key "youtube-music-revanced"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-beta-x86_64" "youtube-music" "google-inc/youtube-music/youtube-music" "x86_64"
	patch "youtube-music-beta-x86_64" "revanced"
	# x86
	get_patches_key "youtube-music-revanced"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-beta-x86" "youtube-music" "google-inc/youtube-music/youtube-music" "x86"
	patch "youtube-music-beta-x86" "revanced"
}
10() {
	revanced_dl
	# Patch Duolingo
	get_patches_key "Duolingo"
	lock_version="1"
	get_apk "com.duolingo" "duolingo-beta" "duolingo-duolingo" "duolingo/duolingo-duolingo/duolingo-language-lessons" "Bundle"
	patch "duolingo-beta" "revanced"
	# Patch Google News Arm64-v8a
	get_patches_key "GoogleNews"
	get_apk "com.google.android.apps.magazines" "googlenews-beta" "google-news" "google-inc/google-news/google-news" "Bundle_extract"
	split_editor "googlenews-beta" "googlenews-beta-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "googlenews-beta-arm64-v8a" "revanced"
}
11() {
	revanced_dl
	# Patch Photomath
	get_patches_key "Photomath"
	get_apk "com.microblink.photomath" "photomath-beta" "photomath" "google-inc/photomath/photomath" "Bundle" "Bundle_extract"
	split_editor "photomath-beta" "photomath-beta"
	patch "photomath-beta" "revanced"
	# Patch Strava:
	get_patches_key "strava"
	get_apkpure "com.strava" "strava-beta-arm64-v8a" "strava-run-hike-2025-health/com.strava" "Bundle"
	patch "strava-beta-arm64-v8a" "revanced"
}
12() {
	revanced_dl
	# Patch Spotjfy Arm64-v8a
	j="i"
	get_patches_key "Spotjfy-revanced"
	get_apkpure "com.spot"$j"fy.music" "spotjfy-beta-arm64-v8a" "spot"$j"fy-music-and-podcasts-for-android/com.spot"$j"fy.music"
	patch "spotjfy-beta-arm64-v8a" "revanced"
	# Patch Proton mail
	get_patches_key "protonmail-revanced"
	get_apkpure "ch.protonmail.android" "protonmail-beta" "proton-mail-encrypted-email/ch.protonmail.android"
	patch "protonmail-beta" "revanced"
}
13() {
	revanced_dl
	# Patch Threads
	get_patches_key "Threads-revanced"
	get_apkpure "com.instagram.barcelona" "threads-beta-arm64-v8a" "threads/com.instagram.barcelona" "Bundle"
	patch "threads-beta-arm64-v8a" "revanced"
	# Patch Prime Video
	get_patches_key "Prime-Video-revanced"
	version="3.0.412"
	get_apk " com.amazon.avod.thirdpartyclient" "prime-video-beta-arm64-v8a" "amazon-prime-video" "amazon-mobile-llc/amazon-prime-video/amazon-prime-video" "arm64-v8a"
	patch "prime-video-beta-arm64-v8a" "revanced"
}
14() {
	revanced_dl
	# Patch Crunchyroll
	get_patches_key "Crunchyroll-revanced"
	url="https://crunchyroll.en.uptodown.com/android/download/1133091557-x" #Use uptodown because apkmirror always ask pass Cloudflare on this app
	url="https://dw.uptodown.com/dwn/$(req "$url" - | $pup -p --charset utf-8 'button#detail-download-button attr{data-url}')"
	req "$url" "crunchyroll-beta"
	split_editor "crunchyroll-beta" "crunchyroll-beta"
	patch "crunchyroll-beta" "revanced"
	# Patch Viber
	get_patches_key "Viber-revanced"
	get_apk "com.viber.voip" "viber-beta" "viber" "viber-media-s-a-r-l/viber/rakuten-viber-messenger"
	patch "viber-beta" "revanced"
}
15() {
	revanced_dl
	# Patch Reddit
	get_patches_key "reddit"
	get_apk "com.reddit.frontpage" "reddit-beta" "reddit" "redditinc/reddit/reddit" "Bundle_extract"
	split_editor "reddit-beta" "reddit-beta"
	patch "reddit-beta" "revanced"
	# Patch Arm64-v8a:
	split_editor "reddit-beta" "reddit-beta-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86_64 split_config.mdpi split_config.ldpi split_config.hdpi split_config.xhdpi split_config.xxhdpi split_config.tvdpi"
	get_patches_key "reddit"
	patch "reddit-beta-arm64-v8a" "revanced"
	# Patch Disney+
	get_patches_key "Disney"
	version="4.20.2+rc1-2025.12.09"
	get_apk "com.disney.disneyplus" "disney-beta" "disney" "disney/disney/disney" "Bundle"
	patch "disney-beta" "revanced"
}
16() {
	revanced_dl
	# Patch ProtonVPN
	get_patches_key "ProtonVPN"
	get_apk "ch.protonvpn.android" "protonvpn-beta" "protonvpn-free-vpn-secure-unlimited-fdroid-version" "proton-technologies-ag/protonvpn-free-vpn-secure-unlimited-fdroid-version/protonvpn-fast-secure-vpn-f-droid-version"
	patch "protonvpn-beta" "revanced"
	# Patch MyFitnessPal
	get_patches_key "MyFitnessPal"
 	url="https://calorie-counter-myfitnesspal.en.uptodown.com/android/download/1010004885" #Use uptodown because apkmirror always ask pass Cloudflare on this app
	url="https://dw.uptodown.com/dwn/$(req "$url" - | $pup -p --charset utf-8 'button#detail-download-button attr{data-url}')"
	req "$url" "MyFitnessPal-beta.apk"
	patch "MyFitnessPal-beta" "revanced"
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
