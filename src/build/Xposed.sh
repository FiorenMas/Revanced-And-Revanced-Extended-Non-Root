#!/bin/bash
# Xposed build
source ./src/build/utils.sh

NPatch_dl(){
	dl_gh "NPatch" "7723mod" "latest"
}
patch_dl(){
	dl_gh "NexAlloy" "gnadgnaoh" "v1.0"
}
1() {
	# Patch Revenge:
	NPatch_dl
	dl_gh "revenge-xposed" "revenge-mod" "latest"
	get_apk "com.discord" "discord" "bundle"
	npatch "discord" "app-release" "revenge"
}
2() {
	NPatch_dl
	patch_dl
	# Patch Facebook:
	version="577.0.0.50.72"
	get_apk "com.facebook.katana" "facebook-arm64-v8a" "bundle" "arm64-v8a" "160-640dpi" "Android 11+"
	npatch "facebook-arm64-v8a" "NexAlloy-nonroot*.apk" "gnadgnaoh" "--sigbypasslv 3"
	# Patch Messenger:
	get_apk "com.facebook.orca" "messenger-arm64-v8a" "apk" "arm64-v8a" "nodpi" "Android 9.0+"
	npatch "messenger-arm64-v8a" "NexAlloy-nonroot*.apk" "gnadgnaoh" "--sigbypasslv 3"
}
3() {
	NPatch_dl
	patch_dl
	# Patch Instagram:
	get_apk "com.instagram.android" "instagram-arm64-v8a" "bundle" "arm64-v8a" "120-640dpi"  "Android 9.0+"
	npatch "instagram-arm64-v8a" "NexAlloy-nonroot*.apk" "gnadgnaoh" "--sigbypasslv 3"
	# Patch Thread:
	get_apk "com.instagram.barcelona" "threads-arm64-v8a" "bundle" "arm64-v8a" "320-480dpi" "Android 9.0+"
	npatch "threads-arm64-v8a" "NexAlloy-nonroot*.apk" "gnadgnaoh" "--sigbypasslv 3"
}
4() {
	dl_gh "NPatch" "7723mod" "Canary-762"
	patch_dl
	# Patch Zalo:
	get_apkpure "com.zing.zalo" "zalo" "bundle"
	npatch "zalo" "NexAlloy*.apk" "gnadgnaoh" "--sigbypasslv 3"
}
5() {
	NPatch_dl
	patch_dl
	# Patch Tiktok:
	get_apk "com.zhiliaoapp.musically" "tiktok" "apk"
	npatch "tiktok" "NexAlloy*.apk" "gnadgnaoh" "--sigbypasslv 3"
	# Patch Tiktok Asian:
	get_apk "com.ss.android.ugc.trill" "tiktok-asian" "apk"
	npatch "tiktok-asian" "NexAlloy*.apk" "gnadgnaoh" "--sigbypasslv 3"
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
