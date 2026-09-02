#!/bin/bash
# Xposed build
source ./src/build/utils.sh

NPatch_dl(){
	dl_gh "LSPatch" "JingMatrix" "latest"
}
patch_dl(){
	dl_gh "NexAlloy" "gnadgnaoh" "v1.0"
}
1() {
	# Patch Revenge:
	NPatch_dl
	dl_gh "revenge-xposed" "revenge-mod" "latest"
	get_apk "com.discord" "discord" "bundle"
	lspatch "discord" "app-release" "revenge"
}
2() {
	NPatch_dl
	patch_dl
	# Patch Facebook:
	version="576.0.0.42.73"
	get_apk "com.facebook.katana" "facebook-arm64-v8a" "bundle" "arm64-v8a" "120-640dpi" "Android 11+"
	lspatch "facebook-arm64-v8a" "NexAlloy-nonroot*.apk" "gnadgnaoh" "--injectdex --sigbypasslv 3"
	# Patch Messenger:
	get_apk "com.facebook.orca" "messenger-arm64-v8a" "apk" "arm64-v8a" "nodpi" "Android 9.0+"
	lspatch "messenger-arm64-v8a" "NexAlloy-nonroot*.apk" "gnadgnaoh" "--injectdex --sigbypasslv 3"
}
3() {
	NPatch_dl
	patch_dl
	# Patch Instagram:
	get_apk "com.instagram.android" "instagram-arm64-v8a" "bundle" "arm64-v8a" "120-640dpi"  "Android 9.0+"
	lspatch "instagram-arm64-v8a" "NexAlloy-nonroot*.apk" "gnadgnaoh" "--injectdex --sigbypasslv 3"
	# Patch Thread:
	get_apk "com.instagram.barcelona" "threads-arm64-v8a" "bundle" "arm64-v8a" "320-480dpi" "Android 9.0+"
	lspatch "threads-arm64-v8a" "NexAlloy-nonroot*.apk" "gnadgnaoh" "--injectdex --sigbypasslv 3"
}
4() {
	NPatch_dl
	patch_dl
	# Patch Zalo:
	get_apk "com.zing.zalo" "zalo" "bundle" "arm64-v8a + armeabi-v7a"
	lspatch "zalo" "NexAlloy-nonroot*.apk" "gnadgnaoh" "--injectdex --sigbypasslv 3"
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
    4)
        4
        ;;
esac
