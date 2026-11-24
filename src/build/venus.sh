#!/bin/bash
# Venus build
source ./src/build/utils.sh
#################################################
# Download requirements
dl_gh "morphe-desktop" "MorpheApp" "latest"
dl_gh "Venus-Patches" "VenusIsJaded" "latest"
#################################################
# Patch Discord
get_patches_key "discord-venus"
get_apk "com.discord" "discord" "bundle"
patch "discord" "venus"
