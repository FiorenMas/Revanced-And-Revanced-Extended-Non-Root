#!/bin/bash
# Twitter Piko
source src/build/utils.sh

piko_shim_dl(){
	dl_gh "morphe-cli" "MorpheApp" "latest"
	dl_gh "piko" "crimera" "prerelease"
	dl_gl "x-shim" "inotia00" "latest"
}
# Patch Twitter Piko:
piko_shim_dl
get_patches_key "twitter-piko"
get_apk "com.twitter.android" "twitter-beta" "bundle"
patch_multi "twitter-beta" "piko-x-shim"