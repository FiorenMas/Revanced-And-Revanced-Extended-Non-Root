#!/bin/bash
# Revanced LisoUseInAIKyrios build
source ./src/build/utils.sh
# Download requirements
revanced_dl(){
	dl_gh "revanced-patches" "LisoUseInAIKyrios" "latest"
	dl_gh "revanced-cli" "LisoUseInAIKyrios" "latest"
}
1() {
	revanced_dl
	# Patch YouTube:
	get_patches_key "youtube-revanced-LisoUseInAIKyrios"
	get_apk "com.google.android.youtube" "youtube" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
	split_editor "youtube" "youtube"
	patch "youtube" "revanced-LisoUseInAIKyrios" "liso"
	# Patch Youtube Arm64-v8a
	get_patches_key "youtube-revanced-LisoUseInAIKyrios" 
	split_editor "youtube" "youtube-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "youtube-arm64-v8a" "revanced-LisoUseInAIKyrios" "liso"
	# Patch Youtube Armeabi-v7a
	get_patches_key "youtube-revanced-LisoUseInAIKyrios" 
	split_editor "youtube" "youtube-armeabi-v7a" "exclude" "split_config.arm64_v8a split_config.x86 split_config.x86_64"
	patch "youtube-armeabi-v7a" "revanced-LisoUseInAIKyrios" "liso"
	# Patch Youtube x86 - REMOVED
	# Patch Youtube x86_64 - REMOVED
}

3() {
	revanced_dl
	# Patch YouTube Music:
	# Arm64-v8a
	get_patches_key "youtube-music-revanced-LisoUseInAIKyrios"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
	patch "youtube-music-arm64-v8a" "revanced-LisoUseInAIKyrios" "liso"
	# Armeabi-v7a
	get_patches_key "youtube-music-revanced-LisoUseInAIKyrios"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-armeabi-v7a" "youtube-music" "google-inc/youtube-music/youtube-music" "armeabi-v7a"
	patch "youtube-music-armeabi-v7a" "revanced-LisoUseInAIKyrios" "liso"
	# x86_64 - REMOVED
	# x86 - REMOVED
}
case "$1" in
    1)
        1
        ;;

    3)
        3
        ;;
esac
