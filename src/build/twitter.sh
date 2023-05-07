#!/bin/bash
# Revanced build
source src/build/tools.sh

dl_gh1 "revanced" 
dl_revanced_integrations "revanced" "0.103.0"

# Patch Twitter
get_patches_key "twitter"
version="9.87.0-release.0"
get_apk "twitter" "twitter" "twitter-inc/twitter/twitter"
patch "twitter" "twitter-revanced"
