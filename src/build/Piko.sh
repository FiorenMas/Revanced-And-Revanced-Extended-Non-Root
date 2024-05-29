#!/bin/bash
# Twitter Piko
source src/build/utils.sh

# Patch Twitter Piko:
patch_piko () {
	dl_gh "revanced-cli" "revanced" "latest"
	get_patches_key "twitter-piko"
	local v apk_name
	if [[ "$1" == "latest" ]]; then
		v="latest" apk_name="stable"
	else
		v="prerelease" apk_name="beta"
	fi
	dl_gh "piko revanced-integrations" "crimera" "$v"
	get_apk "com.twitter.android" "twitter-$apk_name" "twitter" "x-corp/twitter/twitter"
	patch "twitter-$apk_name" "piko"
}
patch_piko $1