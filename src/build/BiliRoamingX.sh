#!/bin/bash
# BiliRoamingX build for chinese only
source ./src/build/utils.sh

#################################################

# Download requirements
dl_gh "revanced-cli" "revanced" "latest"
dl_gh "BiliRoamingX" "BiliRoamingX" "latest"

#################################################

# Patch bilibili:
get_patches_key "bilibili-BiliRoamingX"
get_apk "com.bilibili.app.in" "bilibili" "bilibili" "bilibili/bilibili/bilibili"
patch "bilibili" "BiliRoamingX"