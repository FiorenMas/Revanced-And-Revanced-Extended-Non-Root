#!/bin/bash
# ReVanced Experiments build 
source src/build/utils.sh

#################################################

# Download requirements
dl_gh "ReVancedExperiments" "Aunali321" "latest"
dl_gh "revanced-cli" "revanced" "latest"

#################################################

# Patch Telegram CH Play Version:
get_patches_key "telegram-revanced-experiments"
get_apk "org.telegram.messenger" "telegram" "telegram" "telegram-fz-llc/telegram/telegram"
patch "telegram" "revanced-experiments"

# Patch Telegram Web Version:
get_patches_key "telegram-revanced-experiments"
get_apk "org.telegram.messenger" "telegram-web-version" "telegram-web-version" "telegram-fz-llc/telegram-web-version/telegram-web-version"
patch "telegram-web-version" "revanced-experiments"

# Patch Instagram:
get_patches_key "instagram-revanced-experiments"
version="362.0.0.33.241"
get_apkpure "com.instagram.android" "instagram-arm64-v8a" "instagram-android/com.instagram.android"
patch "instagram-arm64-v8a" "revanced-experiments"
