#!/bin/bash
# Revanced build
source ./src/build/utils.sh

#################################################

# Download requirements
dl_gh "revanced-patches revanced-integrations" "revanced" "prerelease"
dl_gh "revanced-cli" "revanced" "latest"

#################################################

# Patch Facebook:
# Arm64-v8a
get_patches_key "facebook"
version="449.0.0.44.115"
get_apk "com.facebook.katana" "facebook-arm64-v8a-beta" "facebook" "facebook-2/facebook/facebook" "arm64-v8a" "nodpi" "Android 11+"
patch "facebook-arm64-v8a-beta" "revanced"

#################################################

# Patch Pixiv:
get_patches_key "pixiv"
get_apk "jp.pxv.android" "pixiv-beta" "pixiv" "pixiv-inc/pixiv/pixiv"
patch "pixiv-beta" "revanced"

#################################################

# Patch Lightroom:
get_patches_key "lightroom"
get_apk "com.adobe.lrmobile" "lightroom-beta" "lightroom" "adobe/lightroom/lightroom" "arm64-v8a"
patch "lightroom-beta" "revanced"

#################################################

# Patch Windy:
get_patches_key "windy"
version="34.0.2"
get_apk "co.windyapp.android" "windy" "windy-wind-weather-forecast" "windy-weather-world-inc/windy-wind-weather-forecast/windy-wind-weather-forecast"
patch "windy" "revanced"

#################################################

# Patch Tumblr:
get_patches_key "tumblr"
get_apk "com.tumblr" "tumblr-beta" "tumblr" "tumblr-inc/tumblr/tumblr"
patch "tumblr-beta" "revanced"

#################################################