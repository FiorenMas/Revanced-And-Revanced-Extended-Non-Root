#!/bin/bash
# Morphe build
source ./src/build/utils.sh
# Download requirements
morphe_dl(){
	dl_gh "morphe-patches" "MorpheApp" "prerelease"
	dl_gh "morphe-cli" "MorpheApp" "latest"
}
1() {
	morphe_dl

	# Patch YouTube:
	get_patches_key "youtube-morphe"
	prefer_version="21.11.480"
	get_apk "com.google.android.youtube" "youtube-beta" "youtube" "google-inc/youtube/youtube"
	patch "youtube-beta" "morphe" "morphe"
	# Remove unused architectures
	for i in {0..3}; do
		split_arch "youtube-beta" "morphe"
	done
}
2() {
	morphe_dl
	# Patch YouTube Lite Arm64-v8a:
	get_patches_key "youtube-morphe"
	prefer_version="21.11.480"
	get_apk "com.google.android.youtube" "youtube-beta-lite" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
	split_editor "youtube-beta-lite" "youtube-beta-lite-arm64-v8a" "include" "split_config.arm64_v8a split_config.en split_config.xxxhdpi"
	patch "youtube-beta-lite-arm64-v8a" "morphe" "morphe"
	# Patch YouTube Lite Armeabi-v7a:
	get_patches_key "youtube-morphe"
	split_editor "youtube-beta-lite" "youtube-beta-lite-armeabi-v7a" "include" "split_config.armeabi_v7a split_config.en split_config.xxxhdpi"
	patch "youtube-beta-lite-armeabi-v7a" "morphe" "morphe"
	# Patch Reddit:
	get_patches_key "reddit-morphe"
	prefer_version="2026.11.0"
	get_apk "com.reddit.frontpage" "reddit-beta" "reddit" "redditinc/reddit/reddit" "Bundle_extract"
	split_editor "reddit-beta" "reddit"
	patch "reddit-beta" "morphe" "morphe"
	# Patch Arm64-v8a:
	split_editor "reddit-beta" "reddit-arm64-v8a-beta" "exclude" "split_config.armeabi_v7a split_config.x86_64 split_config.mdpi split_config.ldpi split_config.hdpi split_config.xhdpi split_config.xxhdpi split_config.tvdpi"
	get_patches_key "reddit-morphe"
	patch "reddit-arm64-v8a-beta" "morphe" "morphe"
}
3() {
	morphe_dl
	# Patch YouTube Music:
	# Arm64-v8a
	get_patches_key "youtube-music-morphe"
	prefer_version="9.09.52"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-beta-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
	patch "youtube-music-beta-arm64-v8a" "morphe" "morphe"
	# Armeabi-v7a
	get_patches_key "youtube-music-morphe"
	prefer_version="9.09.52"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-beta-armeabi-v7a" "youtube-music" "google-inc/youtube-music/youtube-music" "armeabi-v7a"
	patch "youtube-music-beta-armeabi-v7a" "morphe" "morphe"
	# x86_64
	get_patches_key "youtube-music-morphe"
	prefer_version="9.09.52"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-beta-x86_64" "youtube-music" "google-inc/youtube-music/youtube-music" "x86_64"
	patch "youtube-music-beta-x86_64" "morphe" "morphe"
	# x86
	get_patches_key "youtube-music-morphe"
	prefer_version="9.09.52"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-beta-x86" "youtube-music" "google-inc/youtube-music/youtube-music" "x86"
	patch "youtube-music-beta-x86" "morphe" "morphe"
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
