#!/bin/bash
# BiliRoamingM build for chinese only
source ./src/build/utils.sh
#################################################
# Download requirements
dl_gh "morphe-desktop" "MorpheApp" "latest"
dl_gh "Hushfacebook" "SysAdminDoc" "latest"
#################################################
# Patch Facebook:
get_patches_key "HushFacebook"
get_apk "com.facebook.katana" "facebook-arm64-v8a" "bundle" "arm64-v8a" "320-640dpi" "Android 11+"
patch "facebook-arm64-v8a" "hushfacebook"