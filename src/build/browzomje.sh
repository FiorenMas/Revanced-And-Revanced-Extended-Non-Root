#!/bin/bash
# browzomje build
source ./src/build/utils.sh
#################################################
# Download requirements
dl_gh "morphe-desktop" "MorpheApp" "latest"
dl_gh "browzomje-patches" "browzomje" "latest"
#################################################
# Patch Pinterest
get_patches_key "pinterest-browzomje"
get_apk "com.pinterest" "pinterest" "apk"
patch "pinterest" "browzomje"
