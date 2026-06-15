#!/bin/bash
# docbt build for Google News
source ./src/build/utils.sh
#################################################
# Download requirements
dl_gh "morphe-cli" "MorpheApp" "latest"
dl_gh "patched-up" "docbt" "latest"
#################################################
# Patch Google News Arm64-v8a
get_patches_key "google-news-docbt"
get_apk "com.google.android.apps.magazines" "googlenews" "apk"
patch "googlenews" "docbt" "morphe"