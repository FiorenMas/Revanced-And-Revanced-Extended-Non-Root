#!/bin/bash
# $potjfy build
source src/build/utils.sh

# Download requirements
dl_gh "revanced-patches revanced-cli" "revanced" "latest"

# Patch Spotjfy Arm64-v8a
get_patches_key "Spotjfy-revanced"
j="i"
version="9.0.44.478" #https://github.com/ReVanced/revanced-patches/issues/4958#issuecomment-2883387940
get_apkpure "com.spot"$j"fy.music" "spotjfy-arm64-v8a" "spot"$j"fy-music-and-podcasts-for-android/com.spot"$j"fy.music"
patch "spotjfy-arm64-v8a" "revanced"
