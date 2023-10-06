#!/bin/bash
# Revanced build
source ./src/build/utils.sh

#################################################

# Checking new patch
checker "revanced/revanced-patches" "revanced"

#################################################

# Download requirements
dl_gh "revanced-patches revanced-cli revanced-integrations" "revanced" "latest"

#################################################

# Patch Pixiv:
get_patches_key "pixiv"
get_apk "pixiv" "pixiv" "pixiv-inc/pixiv/pixiv"
patch "pixiv" "revanced"

#################################################

# Patch Lightroom:
get_patches_key "lightroom"
get_apk "lightroom" "lightroom" "adobe/lightroom/lightroom"
patch "lightroom" "revanced"

#################################################

# Patch Windy:
get_patches_key "windy"
get_apk "windy" "windy-wind-weather-forecast" "windy-weather-world-inc/windy-wind-weather-forecast/windy-wind-weather-forecast"
patch "windy" "revanced"

#################################################

# Patch Tumblr:
get_patches_key "tumblr"
version=31.5.0.110
get_apk "tumblr" "tumblr" "tumblr-inc/tumblr/tumblr"
patch "tumblr" "revanced"

#################################################

rm -f patches*.json revanced-patches*.jar revanced-integrations*.apk revanced-cli*.jar
dl_gh "revanced-patches" "revanced" "tags/v2.187.0"
dl_gh "revanced-integrations" "revanced" "tags/v0.115.1"
dl_gh "revanced-cli" "revanced" "tags/v2.22.0"

#################################################

#Patch Tasker:
get_patches_key "tasker"
get_apk "tasker" "tasker" "joaomgcd/tasker/tasker"
_patch "tasker" "revanced"

#################################################

#Patch Nova Launcher:
get_patches_key "nova-launcher"
get_apk "nova-launcher" "nova-launcher" "teslacoil-software/nova-launcher/nova-launcher"
_patch "nova-launcher" "revanced"

#################################################
