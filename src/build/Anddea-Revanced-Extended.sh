#!/bin/bash
# Revanced Extended forked by Anddea build
source src/build/utils.sh
# Download requirements
dl_gh "revanced-patches revanced-integrations" "anddea" "latest"
dl_gh "revanced-cli" "revanced" "v4.6.0"

# Patch YouTube:
get_patches_key "youtube-rve-anddea"
get_apk "com.google.android.youtube" "youtube-stable" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
split_editor "youtube-stable" "youtube-stable"
patch "youtube-stable" "anddea"
# Patch Youtube Arm64-v8a
get_patches_key "youtube-rve-anddea"
split_editor "youtube-stable" "youtube-stable-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
patch "youtube-stable-arm64-v8a" "anddea"
# Patch Youtube Armeabi-v7a
get_patches_key "youtube-rve-anddea"
split_editor "youtube-stable" "youtube-stable-armeabi-v7a" "exclude" "split_config.arm64_v8a split_config.x86 split_config.x86_64"
patch "youtube-stable-armeabi-v7a" "anddea"
# Patch Youtube x86
get_patches_key "youtube-rve-anddea"
split_editor "youtube-stable" "youtube-stable-x86" "exclude" "split_config.arm64_v8a split_config.armeabi_v7a split_config.x86_64"
patch "youtube-stable-x86" "anddea"
# Patch Youtube x86_64
get_patches_key "youtube-rve-anddea"
split_editor "youtube-stable" "youtube-stable-x86_64" "exclude" "split_config.arm64_v8a split_config.armeabi_v7a split_config.x86"
patch "youtube-stable-x86_64" "anddea"

# Patch YouTube Music Extended:
# Arm64-v8a
get_patches_key "youtube-music-rve-anddea"
get_apk "com.google.android.apps.youtube.music" "youtube-music-stable-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
patch "youtube-music-stable-arm64-v8a" "anddea"
# Armeabi-v7a
get_patches_key "youtube-music-rve-anddea"
get_apk "com.google.android.apps.youtube.music" "youtube-music-stable-armeabi-v7a" "youtube-music" "google-inc/youtube-music/youtube-music" "armeabi-v7a"
patch "youtube-music-stable-armeabi-v7a" "anddea"

get_apk "com.google.android.youtube" "youtube-lite" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
# Patch YouTube Lite Arm64-v8a:
get_patches_key "youtube-rve-anddea"
split_editor "youtube-lite" "youtube-lite-arm64-v8a" "include" "split_config.arm64_v8a split_config.en split_config.xhdpi split_config.xxxhdpi"
patch "youtube-lite-arm64-v8a" "anddea"
# Patch YouTube Lite Armeabi-v7a:
get_patches_key "youtube-rve-anddea"
split_editor "youtube-lite" "youtube-lite-armeabi-v7a" "include" "split_config.armeabi_v7a split_config.en split_config.xhdpi split_config.xxxhdpi"
patch "youtube-lite-armeabi-v7a" "anddea"
