#!/bin/bash
# Revanced Extended forked by Anddea build
source src/build/utils.sh
# Download requirements

anddea_dl(){
	dl_gh "revanced-patches" "anddea" "latest"
	dl_gh "morphe-desktop" "MorpheApp" "latest"
}

1() {
	anddea_dl
	# Patch YouTube:
	get_patches_key "youtube-rve-anddea"
	get_apk "com.google.android.youtube" "youtube-stable" "apk"
	patch "youtube-stable" "anddea"
	# Remove unused architectures
	for i in {0..3}; do
		split_arch "youtube-stable" "anddea"
	done
}
2() {
	anddea_dl
	# Patch YouTube Music Extended:
	# Arm64-v8a
	get_patches_key "youtube-music-rve-anddea"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-stable-arm64-v8a" "apk" "arm64-v8a"
	patch "youtube-music-stable-arm64-v8a" "anddea"
	# Armeabi-v7a
	get_patches_key "youtube-music-rve-anddea"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-stable-armeabi-v7a" "apk" "armeabi-v7a"
	patch "youtube-music-stable-armeabi-v7a" "anddea"
	# x86_64
	get_patches_key "youtube-music-rve-anddea"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-stable-x86_64" "apk" "x86_64"
	patch "youtube-music-stable-x86_64" "anddea"
	# x86
	get_patches_key "youtube-music-rve-anddea"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-stable-x86" "apk" "x86"
	patch "youtube-music-stable-x86" "anddea"
}
case "$1" in
    1)
        1
        ;;
    2)
        2
        ;;
esac
