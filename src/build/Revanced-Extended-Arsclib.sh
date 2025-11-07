#!/bin/bash
# Revanced Extended Arsclib build 
source src/build/utils.sh

#################################################

# Download requirements
dl_gh "revanced-patches-arsclib revanced-integrations revanced-cli-arsclib" "inotia00" "latest"

#################################################

# Patch Reddit:
get_patches_key "reddit-rve-arsclib"
get_apk "com.reddit.frontpage" "reddit" "reddit" "redditinc/reddit/reddit" "Bundle_extract"
split_editor "reddit" "reddit"
patch "reddit" "revanced-extended"
mv ./release/reddit-revanced-extended.apk/base.apk ./reddit-revanced-extended.apk
rm -f -d ./release/reddit-revanced-extended.apk
mv ./reddit-revanced-extended.apk ./release/reddit-revanced-extended-arsclib.apk
# Patch Arm64-v8a:
get_patches_key "reddit-rve-arsclib"
split_editor "reddit" "reddit-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86_64 split_config.mdpi split_config.ldpi split_config.hdpi split_config.xxhdpi split_config.tvdpi"
patch "reddit-arm64-v8a" "revanced-extended"
mv ./release/reddit-arm64-v8a-revanced-extended.apk/base.apk ./reddit-arm64-v8a-revanced-extended.apk
rm -f -d ./release/reddit-arm64-v8a-revanced-extended.apk
mv ./reddit-arm64-v8a-revanced-extended.apk ./release/reddit-arm64-v8a-revanced-extended-arsclib.apk