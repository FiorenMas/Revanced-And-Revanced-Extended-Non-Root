#!/bin/bash
# Revanced Extended Arsclib build 
source src/build/utils.sh

#################################################

# Download requirements
dl_gh "revanced-patches-arsclib revanced-integrations revanced-cli-arsclib" "inotia00" "latest"

#################################################

# Patch Reddit:
get_patches_key "reddit-rve"
#version="2024.25.3"
get_apk "com.reddit.frontpage" "reddit" "reddit" "redditinc/reddit/reddit"
patch "reddit" "revanced-extended"
mv ./release/reddit-revanced-extended.apk/base.apk ./reddit-revanced-extended.apk
rm -f -d ./release/reddit-revanced-extended.apk
mv ./reddit-revanced-extended.apk ./release/reddit-revanced-extended.apk
