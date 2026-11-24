#!/bin/bash
# RVX lavinhoque33 build
source ./src/build/utils.sh
# Download requirements
lavinhoque33_dl(){
	dl_gh "revanced-patches" "lavinhoque33" "latest"
	dl_gh "morphe-desktop" "MorpheApp" "latest"
	if ! compgen -G "patches-*.mpp" > /dev/null || ! compgen -G "morphe-desktop-*.jar" > /dev/null; then
		red_log "[-] Missing lavinhoque33 patch bundle or Morphe CLI"
		exit 1
	fi
}
1() {
	lavinhoque33_dl
	# Patch YouTube:
	get_patches_key "youtube-lavinhoque33"
	get_apk "com.google.android.youtube" "youtube" "apk"
	patch "youtube" "lavinhoque33"
	# Remove unused architectures
	for i in {0..3}; do
		get_patches_key "youtube-lavinhoque33"
		split_arch "youtube" "lavinhoque33"
	done
}
2() {
	lavinhoque33_dl
	# Patch YouTube Music (Arm64-v8a):
	get_patches_key "youtube-music-lavinhoque33"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-arm64-v8a" "apk" "arm64-v8a"
	patch "youtube-music-arm64-v8a" "lavinhoque33"
}
case "$1" in
    1)
        1
        ;;
    2)
        2
        ;;
esac
