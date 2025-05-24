#!/bin/bash
# $potjfy build
source src/build/utils.sh

# Download requirements
dl_gh "revanced-patches revanced-cli" "revanced" "latest"

# Patch Spotjfy Arm64-v8a
get_patches_key "Spotjfy-revanced"
j="i"
get_apkpure "com.spot"$j"fy.music" "spotjfy-arm64-v8a" "spot"$j"fy-music-and-podcasts-for-android/com.spot"$j"fy.music" "Bundle"
patch "spotjfy-arm64-v8a" "revanced"
