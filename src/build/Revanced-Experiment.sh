#!/bin/bash
# ReVanced Experiments  build 
source src/build/utils.sh

#################################################

# Download requirements
dl_gh "ReVancedExperiments" "Aunali321" "latest"
dl_gh "revanced-cli" "revanced" "latest"

#################################################

# Patch Telegram CH Play Version:
get_patches_key "telegram-revanced-experiments"
get_apk "org.telegram.messenger" "telegram" "telegram" "telegram-fz-llc/telegram/telegram" "arm64-v8a" "nodpi"
patch "telegram" "revanced-experiments"

# Patch Telegram Web Version:
get_patches_key "telegram-revanced-experiments"
get_apk "org.telegram.messenger" "telegram-web-version" "telegram-web-version" "telegram-fz-llc/telegram-web-version/telegram-web-version"
patch "telegram-web-version" "revanced-experiments"

# Patch Instagram:
get_patches_key "instagram-revanced-experiments"
get_apk "com.instagram.android" "instagram-arm64-v8a" "instagram-instagram" "instagram/instagram-instagram/instagram-instagram" "arm64-v8a" "nodpi"
patch "instagram-arm64-v8a" "revanced-experiments"