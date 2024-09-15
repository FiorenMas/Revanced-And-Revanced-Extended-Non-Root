#!/bin/bash
# Revanced build
source ./src/build/utils.sh

#################################################

# Download requirements
dl_gh "revanced-patches revanced-cli revanced-integrations" "revanced" "latest"

#################################################

# Patch RAR:
get_patches_key "rar"
get_apk "com.rarlab.rar" "rar" "rar" "rarlab-published-by-win-rar-gmbh/rar/rar" "arm64-v8a"
patch "rar" "revanced"

#################################################

# Patch Tiktok:
get_patches_key "tiktok"
get_apk "com.ss.android.ugc.trill" "tiktok" "tik-tok" "tiktok-pte-ltd/tik-tok/tik-tok"
patch "tiktok" "revanced"

#################################################

# Patch Instagram:
# Arm64-v8a
get_patches_key "instagram"
get_apk "com.instagram.android" "instagram-arm64-v8a" "instagram-instagram" "instagram/instagram-instagram/instagram-instagram" "arm64-v8a" "nodpi"
patch "instagram-arm64-v8a" "revanced"

#################################################

# Patch Facebook by PantlessCoding:
# Arm64-v8a
rm -f revanced-patches*.jar
dl_gh "revanced-patches" "PantlessCoding" "latest"
get_patches_key "facebook"
get_apk "com.facebook.katana" "facebook-arm64-v8a-PantlessCoding" "facebook" "facebook-2/facebook/facebook" "arm64-v8a" "nodpi" "Android 11+"
patch "facebook-arm64-v8a-PantlessCoding" "revanced"

#################################################