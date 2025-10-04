#!/bin/bash
# Twitter Piko
source src/build/utils.sh

dl_gh "revanced-cli" "revanced" "latest"
dl_gh "piko" "crimera" "prerelease"

# Patch Twitter Piko:
get_patches_key "twitter-piko"
get_apk "com.twitter.android" "twitter-beta" "twitter" "x-corp/twitter/x-formerly-twitter" "Bundle_extract"
split_editor "twitter-beta" "twitter-beta"
patch "twitter-beta" "piko"
# Patch Twitter Piko Arm64-v8a:
get_patches_key "twitter-piko"
split_editor "twitter-beta" "twitter-arm64-v8a-beta" "exclude" "plit_config.armeabi_v7a split_config.x86 split_config.x86_64 split_config.mdpi split_config.hdpi split_config.xhdpi split_config.xxhdpi split_config.tvdpi"
patch "twitter-arm64-v8a-beta" "piko"