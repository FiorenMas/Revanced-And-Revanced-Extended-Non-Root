#!/bin/bash
# Revanced Extended forked by Anddea build
source src/build/utils.sh

patch_rve_anddea () {
	# Patch YouTube Revanced Extended Anddea:
	dl_gh "revanced-cli" "revanced" "latest"
	local v apk_name
	if [[ "$1" == "latest" ]]; then
		v="latest" apk_name="stable"
	else
		v="prerelease" apk_name="beta"
	fi
	dl_gh "revanced-patches revanced-integrations" "anddea" "$v"
	get_patches_key "youtube-rve-anddea"
	get_apk "com.google.android.youtube" "youtube-$apk_name" "youtube" "google-inc/youtube/youtube"
	patch "youtube-$apk_name" "anddea"
	# Patch Youtube Music:
	# Arm64-v8a
	get_patches_key "youtube-music-rve-anddea"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-$apk_name-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
	patch "youtube-music-$apk_name-arm64-v8a" "anddea"
	# Armeabi-v7a
	get_patches_key "youtube-music-rve-anddea"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-$apk_name-armeabi-v7a" "youtube-music" "google-inc/youtube-music/youtube-music" "armeabi-v7a"
	patch "youtube-music-$apk_name-armeabi-v7a" "anddea"
	# Split architecture:
	rm -f revanced-cli* revanced-patches*.jar *.json
	dl_gh "revanced-cli" "inotia00" "latest"
	dl_gh "revanced-patches" "inotia00" "latest"
	# Split architecture Youtube:
	for i in {0..3}; do
		split_arch "youtube-$apk_name-anddea" "youtube-$apk_name-${archs[i]}-anddea" "$(gen_rip_libs ${libs[i]})"
	done
}
patch_rve_anddea $1
