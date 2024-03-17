#!/bin/bash
# Twitter Piko
source src/build/utils.sh

# Patch Twitter Piko:
patch_piko () {
	get_apk "twitter" "twitter" "x-corp/twitter/twitter"
	dl_gh "revanced-patches revanced-cli" "revanced" "latest"
	mv revanced-patches*.jar _revanced-patches*.jar
	local v apk_name
	if [[ "$1" == "latest" ]]; then
		v="latest" apk_name="stable"
	else
		v="prerelease" apk_name="beta"
	fi
	get_patches_key "twitter-pico"
	if [ -f "./download/twitter.apk" ]; then
		dl_gh "piko revanced-integrations" "crimera" "$v"
		green_log "[+] Patch Twitter Pico:"
		eval java -jar revanced-cli*.jar patch \
		--patch-bundle _revanced-patches*.jar \
		--patch-bundle revanced-patches*.jar \
		--merge revanced-integrations*.apk \
		$excludePatches\
		$includePatches \
		--out=./release/twitter-piko-$apk_name.apk \
		--keystore=./src/ks.keystore \
		./download/twitter.apk
	else
		red_log "[-] Not found Twitter.apk"
		exit 1
	fi
}
patch_piko $1