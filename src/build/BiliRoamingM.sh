#!/bin/bash
# BiliRoamingM build for chinese only
source ./src/build/utils.sh
#################################################
# Download requirements
dl_gh "revanced-cli" "revanced" "v4.6.0"
dl_gh "BiliRoamingM" "sakarie9" "latest"
#################################################
# Patch bilibili:
get_patches_key "bilibili-BiliRoamingM"
get_apk "com.bilibili.app.in" "bilibili" "bilibili" "bilibili/bilibili/bilibili" "Bundle_extract"
split_editor "bilibili" "bilibili"
patch "bilibili" "BiliRoamingM"
# Patch bilibili Arm64-v8a:
get_patches_key "bilibili-BiliRoamingM"
split_editor "bilibili" "bilibili-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
patch "bilibili-arm64-v8a" "BiliRoamingM"