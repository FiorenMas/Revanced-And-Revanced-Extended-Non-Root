#!/bin/bash
# Revanced Extended forked by Anddea build
source src/build/utils.sh
# Download requirements

anddea_dl(){
	dl_gh "revanced-patches" "anddea" "prerelease"
	dl_gh "morphe-cli" "MorpheApp" "latest"
}

1() {
	anddea_dl
	# Patch YouTube:
	get_patches_key "youtube-rve-anddea"
	get_apk "com.google.android.youtube" "youtube-beta" "youtube" "google-inc/youtube/youtube"
	patch "youtube-beta" "anddea" "morphe"
	# Remove unused architectures
	for i in {0..3}; do
		apk_editor "youtube-beta" "${archs[i]}" ${libs[i]}
	done
	# Patch Youtube Arm64-v8a
	get_patches_key "youtube-rve-anddea"
	patch "youtube-beta-arm64-v8a" "anddea" "morphe"
	# Patch Youtube Armeabi-v7a
	get_patches_key "youtube-rve-anddea"
	patch "youtube-beta-armeabi-v7a" "anddea" "morphe"
	# Patch Youtube x86
	get_patches_key "youtube-rve-anddea"
	patch "youtube-beta-x86" "anddea" "morphe"
	# Patch Youtube x86_64
	get_patches_key "youtube-rve-anddea"
	patch "youtube-beta-x86_64" "anddea" "morphe"
}
2() {
	anddea_dl
	# Patch YouTube Music Extended:
	# Arm64-v8a
	get_patches_key "youtube-music-rve-anddea"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-beta-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
	patch "youtube-music-beta-arm64-v8a" "anddea" "morphe"
	# Armeabi-v7a
	get_patches_key "youtube-music-rve-anddea"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-beta-armeabi-v7a" "youtube-music" "google-inc/youtube-music/youtube-music" "armeabi-v7a"
	patch "youtube-music-beta-armeabi-v7a" "anddea" "morphe"
	# x86_64
	get_patches_key "youtube-music-rve-anddea"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-beta-x86_64" "youtube-music" "google-inc/youtube-music/youtube-music" "x86_64"
	patch "youtube-music-beta-x86_64" "anddea" "morphe"
	# x86
	get_patches_key "youtube-music-rve-anddea"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-beta-x86" "youtube-music" "google-inc/youtube-music/youtube-music" "x86"
	patch "youtube-music-beta-x86" "anddea" "morphe"
}
case "$1" in
    1)
        1
        ;;
    2)
        2
        ;;
esac
