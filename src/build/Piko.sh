#!/bin/bash
# Twitter Piko
source src/build/utils.sh

dl_gh "revanced-cli" "revanced" "v4.6.0"
dl_gh "piko revanced-integrations" "crimera" "latest"

# Patch Twitter Piko:
get_patches_key "twitter-piko"
get_apk "com.twitter.android" "twitter-stable" "twitter" "x-corp/twitter/x" "Bundle_extract"
split_editor "twitter-stable" "twitter-stable"
patch "twitter-stable" "piko"
# Patch Twitter Piko Arm64-v8a:
get_patches_key "twitter-piko"
split_editor "twitter-stable" "twitter-arm64-v8a-stable" "exclude" "plit_config.armeabi_v7a split_config.x86 split_config.x86_64 split_config.mdpi split_config.hdpi split_config.xhdpi split_config.xxhdpi split_config.tvdpi"
patch "twitter-arm64-v8a-stable" "piko"
