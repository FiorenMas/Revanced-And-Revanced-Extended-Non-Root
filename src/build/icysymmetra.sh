#!/bin/bash
# icysymmetra build for Tiktok
source ./src/build/utils.sh
#################################################
# Download requirements
dl_gh "morphe-cli" "MorpheApp" "latest"
dl_gh "tiktok-patches-for-morphe" "icysymmetra" "latest"
#################################################
# Patch Tiktok:
get_patches_key "tiktok-icysymmetra"
get_apk "com.zhiliaoapp.musically" "tiktok" "apk" "arm64-v8a + armeabi-v7a" "nodpi"
patch "tiktok" "icysymmetra" "morphe"