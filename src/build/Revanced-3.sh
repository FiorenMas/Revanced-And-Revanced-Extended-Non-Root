#!/bin/bash
# Revanced build
source ./src/build/utils.sh

#################################################

# Download requirements
dl_gh "revanced-patches revanced-cli revanced-integrations" "revanced" "latest"

#################################################

# Patch Facebook:
# Arm64-v8a
get_patches_key "facebook"
version="449.0.0.44.115"
get_apk "com.facebook.katana" "facebook-arm64-v8a" "facebook" "facebook-2/facebook/facebook" "arm64-v8a" "nodpi" "Android 11+"
patch "facebook-arm64-v8a" "revanced"

#################################################

# Patch Pixiv:
get_patches_key "pixiv"
get_apk "jp.pxv.android" "pixiv" "pixiv" "pixiv-inc/pixiv/pixiv"
patch "pixiv" "revanced"

#################################################

# Patch Lightroom:
get_patches_key "lightroom"
get_apk "com.adobe.lrmobile" "lightroom" "lightroom" "adobe/lightroom/lightroom" "arm64-v8a"
patch "lightroom" "revanced"

#################################################

# Patch Windy:
get_patches_key "windy"
version="34.0.2"
get_apk "co.windyapp.android" "windy" "windy-wind-weather-forecast" "windy-weather-world-inc/windy-wind-weather-forecast/windy-wind-weather-forecast"
patch "windy" "revanced"

#################################################

# Patch Tumblr:
get_patches_key "tumblr"
get_apk "com.tumblr" "tumblr" "tumblr" "tumblr-inc/tumblr/tumblr"
patch "tumblr" "revanced"

#################################################