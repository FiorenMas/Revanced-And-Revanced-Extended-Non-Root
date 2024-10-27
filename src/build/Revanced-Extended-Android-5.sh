#!/bin/bash
# Revanced Extended for android 5
source src/build/utils.sh

# Download requirements
dl_gh "revanced-patches-android5 revanced-integrations" "d4n3436" "latest"
dl_gh "revanced-cli" "revanced" "v3.1.1"

# Patch YouTube Extended for android 5:
get_patches_key "youtube-revanced-extended-5"
version="16.40.36"
get_apk "com.google.android.youtube" "youtube" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
split_editor "youtube" "youtube"
patch "youtube" "revanced-extended-android-5"
# Patch Youtube Arm64-v8a
get_patches_key "youtube-revanced-extended-5"
split_editor "youtube" "youtube-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
patch "youtube-arm64-v8a" "revanced-extended-android-5"
# Patch Youtube Armeabi-v7a
get_patches_key "youtube-revanced-extended-5"
split_editor "youtube" "youtube-armeabi-v7a" "exclude" "split_config.arm64_v8a split_config.x86 split_config.x86_64"
patch "youtube-armeabi-v7a" "revanced-extended-android-5"
# Patch Youtube x86
get_patches_key "youtube-revanced-extended-5"
split_editor "youtube" "youtube-x86" "exclude" "split_config.arm64_v8a split_config.armeabi_v7a split_config.x86_64"
patch "youtube-x86" "revanced-extended-android-5"
# Patch Youtube x86_64
get_patches_key "youtube-revanced-extended-5"
split_editor "youtube" "youtube-x86_64" "exclude" "split_config.arm64_v8a split_config.armeabi_v7a split_config.x86"
patch "youtube-x86_64" "revanced-extended-android-5"
