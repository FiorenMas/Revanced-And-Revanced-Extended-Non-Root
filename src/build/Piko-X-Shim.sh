#!/bin/bash
# Twitter Piko
source src/build/utils.sh

piko_shim_dl(){
	dl_gh "morphe-desktop" "MorpheApp" "latest"
	dl_gh "piko" "crimera" "latest"
	dl_gl "x-shim" "inotia00" "latest"
}
# Patch Twitter Piko:
piko_shim_dl
get_patches_key "twitter-piko"
get_apk "com.twitter.android" "twitter" "bundle"
patch_multi "twitter" "piko-x-shim"
