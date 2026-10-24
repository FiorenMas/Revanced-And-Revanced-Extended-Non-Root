#!/bin/bash
# Twitter Piko
source src/build/utils.sh

piko_shim_dl(){
	dl_gh "morphe-desktop" "MorpheApp" "latest"
	dl_gh "piko-newx" "crimera" "latest"
}
# Patch Twitter Piko:
piko_shim_dl
get_patches_key "twitter-piko"
get_apk "com.twitter.android" "twitter" "bundle"
patch_multi "twitter" "piko-newx"