#!/bin/bash
# Revanced build
source ./src/build/utils.sh

#################################################

# Download requirements
dl_gh "revanced-patches revanced-integrations" "revanced" "prerelease"
dl_gh "revanced-cli" "revanced" "latest"

#################################################

# Patch Google photos:
# Arm64-v8a
get_patches_key "gg-photos"
version="6.94.0.662644291"
get_apk "com.google.android.apps.photos" "gg-photos-arm64-v8a-beta" "photos" "google-inc/photos/photos" "arm64-v8a"
patch "gg-photos-arm64-v8a-beta" "revanced"

##################################################################################################

# Patch Facebook:
# Arm64-v8a
get_patches_key "facebook"
get_apk "com.facebook.katana" "facebook-arm64-v8a-beta" "facebook" "facebook-2/facebook/facebook" "arm64-v8a" "nodpi" "Android 11+"
patch "facebook-arm64-v8a-beta" "revanced"

#################################################

# Patch Pixiv:
get_patches_key "pixiv"
version="6.120.0"
get_apk "jp.pxv.android" "pixiv-beta" "pixiv" "pixiv-inc/pixiv/pixiv"
patch "pixiv-beta" "revanced"

#################################################

# Patch Lightroom:
get_patches_key "lightroom"
version="9.2.2"
get_apk "com.adobe.lrmobile" "lightroom-beta" "lightroom" "adobe/lightroom/lightroom" "arm64-v8a"
patch "lightroom-beta" "revanced"

#################################################

# Patch Tumblr:
get_patches_key "tumblr"
version="35.0.0.110"
get_apk "com.tumblr" "tumblr-beta" "tumblr" "tumblr-inc/tumblr/tumblr"
patch "tumblr-beta" "revanced"

#################################################

# Patch RAR:
get_patches_key "rar"
get_apk "com.rarlab.rar" "rar-beta" "rar" "rarlab-published-by-win-rar-gmbh/rar/rar" "arm64-v8a"
patch "rar-beta" "revanced"

#################################################
