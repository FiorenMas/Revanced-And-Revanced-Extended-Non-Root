#!/bin/bash
# Xposed build
source ./src/build/utils.sh

LSPatch_dl(){
	dl_gh "LSPatch" "JingMatrix" "latest"
}
patch_dl(){
	dl_gh "NexAlloy" "gnadgnaoh" "v1.0"
}
1() {
	# Patch Revenge:
	LSPatch_dl
	dl_gh "revenge-xposed" "revenge-mod" "latest"
	get_apk "com.discord" "discord" "bundle"
	lspatch "discord" "app-release" "revenge"
}
2() {
	LSPatch_dl
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
	LSPatch_dl
	patch_dl
	# Patch Instagram:
	get_apk "com.instagram.android" "instagram-arm64-v8a" "bundle" "arm64-v8a" "120-640dpi"  "Android 9.0+"
	lspatch "instagram-arm64-v8a" "NexAlloy-nonroot*.apk" "gnadgnaoh" "--injectdex --sigbypasslv 3"
	# Patch Thread:
	get_apk "com.instagram.barcelona" "threads-arm64-v8a" "bundle" "arm64-v8a" "160-640dpi" "Android 9.0+"
	lspatch "threads-arm64-v8a" "NexAlloy-nonroot*.apk" "gnadgnaoh" "--injectdex --sigbypasslv 3"
}
4() {
	LSPatch_dl
	patch_dl
	# Patch Zalo:
	get_apkpure "com.zing.zalo" "zalo" "bundle"
	lspatch "zalo" "NexAlloy*.apk" "gnadgnaoh" "--injectdex --sigbypasslv 3"
}
5() {
	LSPatch_dl
	patch_dl
	# Patch Tiktok:
	get_apk "com.zhiliaoapp.musically" "tiktok" "apk"
	lspatch "tiktok" "NexAlloy*.apk" "gnadgnaoh" "--injectdex --sigbypasslv 3"
	# Patch Tiktok Asian:
	get_apk "com.ss.android.ugc.trill" "tiktok-asian" "apk"
	lspatch "tiktok-asian" "NexAlloy*.apk" "gnadgnaoh" "--injectdex --sigbypasslv 3"
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
