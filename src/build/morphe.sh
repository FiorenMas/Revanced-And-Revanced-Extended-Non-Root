#!/bin/bash
# Morphe build
source ./src/build/utils.sh
# Download requirements
morphe_dl(){
	dl_gh "morphe-patches" "MorpheApp" "latest"
	dl_gh "morphe-cli" "MorpheApp" "latest"
}
1() {
	morphe_dl
	# Patch YouTube:
	get_patches_key "youtube-morphe"
	get_apk "com.google.android.youtube" "youtube" "youtube" "google-inc/youtube/youtube"
	patch "youtube" "morphe" "morphe"
	# Remove unused architectures
	for i in {0..3}; do
	  apk_editor "youtube" "${archs[i]}" ${libs[i]}
	done
	# Patch Youtube Arm64-v8a
	get_patches_key "youtube-morphe"
	patch "youtube-arm64-v8a" "morphe" "morphe"
	# Patch Youtube Armeabi-v7a
	get_patches_key "youtube-morphe"
	patch "youtube-armeabi-v7a" "morphe" "morphe"
	# Patch Youtube x86
	get_patches_key "youtube-morphe" 
	patch "youtube-x86" "morphe" "morphe"
	# Patch Youtube x86_64
	get_patches_key "youtube-morphe" 
	patch "youtube-x86_64" "morphe" "morphe"
	
	#get_patches_key "youtube-morphe"
	#get_apk "com.google.android.youtube" "youtube" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
	#split_editor "youtube" "youtube"
	#patch "youtube" "morphe" "morphe"
	# Patch Youtube Arm64-v8a
	#get_patches_key "youtube-morphe" 
	#split_editor "youtube" "youtube-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	#patch "youtube-arm64-v8a" "morphe" "morphe"
	# Patch Youtube Armeabi-v7a
	#get_patches_key "youtube-morphe" 
	#split_editor "youtube" "youtube-armeabi-v7a" "exclude" "split_config.arm64_v8a split_config.x86 split_config.x86_64"
	#patch "youtube-armeabi-v7a" "morphe" "morphe"
	# Patch Youtube x86
	#get_patches_key "youtube-morphe" 
	#split_editor "youtube" "youtube-x86" "exclude" "split_config.arm64_v8a split_config.armeabi_v7a split_config.x86_64"
	#patch "youtube-x86" "morphe" "morphe"
	# Patch Youtube x86_64
	#get_patches_key "youtube-morphe" 
	#split_editor "youtube" "youtube-x86_64" "exclude" "split_config.arm64_v8a split_config.armeabi_v7a split_config.x86"
	#patch "youtube-x86_64" "morphe" "morphe"
}
2() {
	morphe_dl
	# Patch YouTube Lite Arm64-v8a:
	#get_patches_key "youtube-morphe"
	#get_apk "com.google.android.youtube" "youtube-lite" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
	#split_editor "youtube-lite" "youtube-lite-arm64-v8a" "include" "split_config.arm64_v8a split_config.en split_config.xxxhdpi"
	#patch "youtube-lite-arm64-v8a" "morphe" "morphe"
	# Patch YouTube Lite Armeabi-v7a:
	#get_patches_key "youtube-morphe"
	#split_editor "youtube-lite" "youtube-lite-armeabi-v7a" "include" "split_config.armeabi_v7a split_config.en split_config.xxxhdpi"
	#patch "youtube-lite-armeabi-v7a" "morphe" "morphe"
}
3() {
	morphe_dl
	# Patch YouTube Music:
	# Arm64-v8a
	get_patches_key "youtube-music-morphe"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
	patch "youtube-music-arm64-v8a" "morphe" "morphe"
	# Armeabi-v7a
	get_patches_key "youtube-music-morphe"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-armeabi-v7a" "youtube-music" "google-inc/youtube-music/youtube-music" "armeabi-v7a"
	patch "youtube-music-armeabi-v7a" "morphe" "morphe"
	# x86_64
	get_patches_key "youtube-music-morphe"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-x86_64" "youtube-music" "google-inc/youtube-music/youtube-music" "x86_64"
	patch "youtube-music-x86_64" "morphe" "morphe"
	# x86
	get_patches_key "youtube-music-morphe"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-x86" "youtube-music" "google-inc/youtube-music/youtube-music" "x86"
	patch "youtube-music-x86" "morphe" "morphe"
}
case "$1" in
    1)
        1
        ;;
    2)
        2
        ;;
    3)
        3
        ;;
esac