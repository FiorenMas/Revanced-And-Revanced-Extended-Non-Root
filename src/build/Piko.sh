#!/bin/bash
# Twitter Piko
source src/build/utils.sh

# Patch Twitter Piko:
patch_piko () {
	dl_gh "revanced-cli" "revanced" "v4.6.0"
	get_patches_key "twitter-piko"
	local v apk_name
	if [[ "$1" == "latest" ]]; then
		v="latest" apk_name="stable"
	else
		v="prerelease" apk_name="beta"
	fi
	dl_gh "piko revanced-integrations" "crimera" "$v"
	get_apk "com.twitter.android" "twitter-$apk_name" "twitter" "x-corp/twitter/x-previously-twitter" "Bundle_extract"
	split_editor "twitter-$apk_name" "twitter-$apk_name"
	patch "twitter-$apk_name" "piko"
	# Patch Twitter Piko Arm64-v8a:
	get_patches_key "twitter-piko"
	split_editor "twitter-$apk_name" "twitter-arm64-v8a-$apk_name" "exclude" "plit_config.armeabi_v7a split_config.x86 split_config.x86_64 split_config.mdpi split_config.hdpi split_config.xhdpi split_config.xxhdpi split_config.tvdpi"
	patch "twitter-arm64-v8a-$apk_name" "piko"
}
patch_piko $1
