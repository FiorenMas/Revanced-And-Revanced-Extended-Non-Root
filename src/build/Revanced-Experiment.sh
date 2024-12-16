#!/bin/bash
# ReVanced Experiments  build 
source src/build/utils.sh

#################################################

# Download requirements
dl_gh "ReVancedExperiments" "Aunali321" "latest"
dl_gh "revanced-cli" "revanced" "latest"

#################################################

# Patch Telegram:
get_patches_key "telegram-revanced-experiments"
get_apk "org.telegram.messenger" "telegram" "telegram" "telegram-fz-llc/telegram/telegram" "arm64-v8a" "nodpi"
patch "telegram" "revanced-experiments"
