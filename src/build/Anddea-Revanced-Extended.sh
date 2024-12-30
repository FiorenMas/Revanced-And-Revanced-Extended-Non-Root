#!/bin/bash
# Revanced Extended forked by Anddea build
source src/build/utils.sh
# Download requirements
dl_gh "revanced-patches" "anddea" "latest"
dl_gh "revanced-cli" "inotia00" "latest"

#Disabled because lastest RVE Anddea patch youtube not have splits apk on APKMirror
# Patch YouTube:
#get_patches_key "youtube-rve-anddea"
#get_apk "com.google.android.youtube" "youtube-stable" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
#split_editor "youtube-stable" "youtube-stable"
#patch "youtube-stable" "anddea" "inotia"
# Patch Youtube Arm64-v8a
#get_patches_key "youtube-rve-anddea"
#split_editor "youtube-stable" "youtube-stable-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
#patch "youtube-stable-arm64-v8a" "anddea" "inotia"
# Patch Youtube Armeabi-v7a
#get_patches_key "youtube-rve-anddea"
#split_editor "youtube-stable" "youtube-stable-armeabi-v7a" "exclude" "split_config.arm64_v8a split_config.x86 split_config.x86_64"
#patch "youtube-stable-armeabi-v7a" "anddea" "inotia"
# Patch Youtube x86
#get_patches_key "youtube-rve-anddea"
#split_editor "youtube-stable" "youtube-stable-x86" "exclude" "split_config.arm64_v8a split_config.armeabi_v7a split_config.x86_64"
#patch "youtube-stable-x86" "anddea" "inotia"
# Patch Youtube x86_64
#get_patches_key "youtube-rve-anddea"
#split_editor "youtube-stable" "youtube-stable-x86_64" "exclude" "split_config.arm64_v8a split_config.armeabi_v7a split_config.x86"
#patch "youtube-stable-x86_64" "anddea" "inotia"
# Patch YouTube:
get_patches_key "youtube-rve-anddea"
get_apk "com.google.android.youtube" "youtube-stable" "youtube" "google-inc/youtube/youtube"
patch "youtube-stable" "anddea" "inotia"
# Split architecture Youtube:
get_patches_key "youtube-rve-anddea"
for i in {0..3}; do
  split_arch "youtube-stable" "anddea" "$(gen_rip_libs ${libs[i]})"
done

# Patch YouTube Music Extended:
# Arm64-v8a
get_patches_key "youtube-music-rve-anddea"
get_apk "com.google.android.apps.youtube.music" "youtube-music-stable-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
patch "youtube-music-stable-arm64-v8a" "anddea" "inotia"
# Armeabi-v7a
get_patches_key "youtube-music-rve-anddea"
get_apk "com.google.android.apps.youtube.music" "youtube-music-stable-armeabi-v7a" "youtube-music" "google-inc/youtube-music/youtube-music" "armeabi-v7a"
patch "youtube-music-stable-armeabi-v7a" "anddea" "inotia"

#Disabled because lastest RVE Anddea patch youtube not have splits apk on APKMirror
#get_apk "com.google.android.youtube" "youtube-lite-beta" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
# Patch YouTube Lite Arm64-v8a:
#get_patches_key "youtube-rve-anddea"
#split_editor "youtube-lite-beta" "youtube-lite-beta-arm64-v8a" "include" "split_config.arm64_v8a split_config.en split_config.xhdpi split_config.xxxhdpi"
#patch "youtube-lite-beta-arm64-v8a" "anddea" "inotia"
# Patch YouTube Lite Armeabi-v7a:
#get_patches_key "youtube-rve-anddea"
#split_editor "youtube-lite-beta" "youtube-lite-beta-armeabi-v7a" "include" "split_config.armeabi_v7a split_config.en split_config.xhdpi split_config.xxxhdpi"
#patch "youtube-lite-beta-armeabi-v7a" "anddea" "inotia"
