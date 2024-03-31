#!/bin/bash
# ReX forked by anddea build
source src/build/utils.sh

patch_ReX_anddea () {
	# Patch YouTube ReX anddea:
	dl_gh "revanced-cli" "inotia00" "latest"
	get_patches_key "youtube-ReX-anddea"
	local v apk_name
	if [[ "$1" == "latest" ]]; then
		v="latest" apk_name="stable"
	else
		v="prerelease" apk_name="beta"
	fi
	dl_gh " revanced-patches revanced-integrations" "anddea" "$v"
	get_ver "Hide general ads" "com.google.android.youtube"
	get_apk "youtube-$apk_name" "youtube" "google-inc/youtube/youtube"
	patch "youtube-$apk_name" "ReX-anddea" "inotia"
	# Split architecture Youtube:
	rm -f revanced-cli*
	dl_gh "revanced-cli" "FiorenMas" "latest"
	get_patches_key "youtube-ReX-anddea"
	for i in {0..3}; do
		split_arch "youtube-$apk_name" "youtube-$apk_name-${archs[i]}-ReX-anddea" "$(gen_rip_libs ${libs[i]})"
	done
}
patch_ReX_anddea $1