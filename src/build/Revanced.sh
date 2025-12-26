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
	# Patch Youtube x86 - REMOVED
	# Patch Youtube x86_64 - REMOVED
}
2() {
	revanced_dl
	# Patch Messenger:
	# Arm64-v8a
	get_patches_key "messenger"
	get_apkpure "com.facebook.orca" "messenger-arm64-v8a" "facebook-messenger/com.facebook.orca"
	patch "messenger-arm64-v8a" "revanced"
	# Patch Facebook:
	# Arm64-v8a
	get_patches_key "facebook"
 	get_apkpure "com.facebook.katana" "facebook-arm64-v8a" "facebook/com.facebook.katana"
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
	get_patches_key "gg-photos"
 	version="7.32.0.765953717"
	get_apk "com.google.android.apps.photos" "gg-photos-armeabi-v7a" "photos" "google-inc/photos/google-photos" "armeabi-v7a" "nodpi"
	patch "gg-photos-armeabi-v7a" "revanced"
	# x86 - REMOVED
	# x86_64 - REMOVED
}
4() {
	revanced_dl

	# Patch Instagram:
	# Arm64-v8a
	get_patches_key "instagram"
 	get_apkpure "com.instagram.android" "instagram-arm64-v8a" "instagram-android/com.instagram.android" "Bundle"
	patch "instagram-arm64-v8a" "revanced"
}
5() {
    echo "Pixiv removed"
}
6() {
	revanced_dl

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
	# x86_64 - REMOVED
	# x86 - REMOVED
}
10() {
	revanced_dl
	# Patch Duolingo
	get_patches_key "Duolingo"
	lock_version="1"
	get_apk "com.duolingo" "duolingo" "duolingo-duolingo" "duolingo/duolingo-duolingo/duolingo-language-lessons" "Bundle"
	patch "duolingo" "revanced"

}
11() {
	revanced_dl

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

}
14() {
    echo "Apps in this batch (Crunchyroll, Viber) have been removed."
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

}
16() {
	revanced_dl
	# Patch ProtonVPN
	get_patches_key "ProtonVPN"
	get_apk "ch.protonvpn.android" "protonvpn" "protonvpn-free-vpn-secure-unlimited-fdroid-version" "proton-technologies-ag/protonvpn-free-vpn-secure-unlimited-fdroid-version/protonvpn-fast-secure-vpn-f-droid-version"
	patch "protonvpn" "revanced"
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

    6)
        6
        ;;
    7)
        7
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
