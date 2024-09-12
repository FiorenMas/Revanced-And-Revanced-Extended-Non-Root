#!/bin/bash
# Revanced build
source ./src/build/utils.sh

#################################################

# Download requirements
dl_gh "revanced-patches revanced-integrations" "revanced" "prerelease"
dl_gh "revanced-cli" "revanced" "latest"

#################################################

# Patch RAR:
get_patches_key "rar"
get_apk "com.rarlab.rar" "rar-beta" "rar" "rarlab-published-by-win-rar-gmbh/rar/rar" "arm64-v8a"
patch "rar-beta" "revanced"

#################################################

# Patch Tiktok:
get_patches_key "tiktok"
get_apk "com.ss.android.ugc.trill" "tiktok-beta" "tik-tok" "tiktok-pte-ltd/tik-tok/tik-tok"
patch "tiktok-beta" "revanced"

#################################################

# Patch Instagram:
# Arm64-v8a
get_patches_key "instagram"
get_apk "com.instagram.android" "instagram-arm64-v8a-beta" "instagram-instagram" "instagram/instagram-instagram/instagram-instagram" "arm64-v8a" "nodpi"
patch "instagram-arm64-v8a-beta" "revanced"

#################################################