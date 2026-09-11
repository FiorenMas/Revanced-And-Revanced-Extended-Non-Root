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
	version="577.0.0.50.72"
	get_apk "com.facebook.katana" "facebook-arm64-v8a" "bundle" "arm64-v8a" "160-640dpi" "Android 11+"
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
	dl_gh "NPatch" "7723mod" "v1.0.5"
	dl_gh "NexAlloy" "gnadgnaoh" "v1.1"
	# Patch Zalo:
	get_apk "com.zing.zalo" "zalo" "bundle" "arm64-v8a + armeabi-v7a"
	npatch "zalo" "NexAlloy*.apk" "gnadgnaoh" "--injectdex --sigbypasslv 3"
}
5() {
	NPatch_dl
	patch_dl
	# Patch Tiktok:
	get_apk "com.zhiliaoapp.musically" "tiktok" "apk"
	lspatch "tiktok" "NexAlloy*.apk" "gnadgnaoh"
	# Patch Tiktok Asian:
	get_apk "com.ss.android.ugc.trill" "tiktok-asian" "apk"
	lspatch "tiktok-asian" "NexAlloy*.apk" "gnadgnaoh"
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
    5)
        5
        ;;
esac
