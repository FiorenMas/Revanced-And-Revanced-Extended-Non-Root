#!/bin/bash
# Revanced Extended forked by Anddea build
source src/build/utils.sh
# Download requirements
revanced_dl(){
	dl_gh "revanced-patches revanced-integrations" "anddea" "latest"
	dl_gh "revanced-cli" "inotia00" "latest"
}

1() {
	revanced_dl
	# Patch YouTube:
	get_patches_key "youtube-rve-anddea"
	get_apk "com.google.android.youtube" "youtube" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
	split_editor "youtube" "youtube"
	patch "youtube" "anddea" "inotia"
	# Patch Youtube Arm64-v8a
	get_patches_key "youtube-rve-anddea"
	split_editor "youtube" "youtube-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "youtube-arm64-v8a" "anddea" "inotia"
	# Patch Youtube Armeabi-v7a
	get_patches_key "youtube-rve-anddea"
	split_editor "youtube" "youtube-armeabi-v7a" "exclude" "split_config.arm64_v8a split_config.x86 split_config.x86_64"
	patch "youtube-armeabi-v7a" "anddea" "inotia"
	# Patch Youtube x86
	get_patches_key "youtube-rve-anddea"
	split_editor "youtube" "youtube-x86" "exclude" "split_config.arm64_v8a split_config.armeabi_v7a split_config.x86_64"
	patch "youtube-x86" "anddea" "inotia"
	# Patch Youtube x86_64
	get_patches_key "youtube-rve-anddea"
	split_editor "youtube" "youtube-x86_64" "exclude" "split_config.arm64_v8a split_config.armeabi_v7a split_config.x86"
	patch "youtube-x86_64" "anddea" "inotia"
}
2() {
	revanced_dl
	# Patch YouTube Music Extended:
	# Arm64-v8a
	get_patches_key "youtube-music-rve-anddea"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
	patch "youtube-music-arm64-v8a" "anddea" "inotia"
	# Armeabi-v7a
	get_patches_key "youtube-music-rve-anddea"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-armeabi-v7a" "youtube-music" "google-inc/youtube-music/youtube-music" "armeabi-v7a"
	patch "youtube-music-armeabi-v7a" "anddea" "inotia"
}
3() {
	revanced_dl
	get_apk "com.google.android.youtube" "youtube-lite" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
	# Patch YouTube Lite Arm64-v8a:
	get_patches_key "youtube-rve-anddea"
	split_editor "youtube-lite" "youtube-lite-arm64-v8a" "include" "split_config.arm64_v8a split_config.en split_config.xhdpi split_config.xxxhdpi"
	patch "youtube-lite-arm64-v8a" "anddea" "inotia"
	# Patch YouTube Lite Armeabi-v7a:
	get_patches_key "youtube-rve-anddea"
	split_editor "youtube-lite" "youtube-lite-armeabi-v7a" "include" "split_config.armeabi_v7a split_config.en split_config.xhdpi split_config.xxxhdpi"
	patch "youtube-lite-armeabi-v7a" "anddea" "inotia"
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
esac
