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
get_apk "com.bilibili.app.in" "bilibili" "bilibili" "bilibili/bilibili/bilibili"
patch "bilibili" "BiliRoamingM"