#!/bin/bash
# Xposed build
source ./src/build/utils.sh

NPatch_dl(){
	telegram_dl 
}
patch_dl(){
	dl_gh "NexAlloy" "gnadgnaoh" "latest"
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
	get_apk "com.facebook.katana" "facebook-arm64-v8a" "bundle" "arm64-v8a" " nodpi" "Android 11+"
	npatch "facebook-arm64-v8a" "NexAlloy-nonroot-release*.apk" "gnadgnaoh" "--injectdex --sigbypasslv 3"
	# Patch Messenger:
	get_apk "com.facebook.orca" "messenger-arm64-v8a" "apk" "arm64-v8a" "nodpi" "Android 9.0+"
	npatch "messenger-arm64-v8a" "NexAlloy-nonroot-release*.apk" "gnadgnaoh" "--injectdex --sigbypasslv 3"
}
3() {
	NPatch_dl
	patch_dl
	# Patch Instagram:
	get_apk "com.instagram.android" "instagram-arm64-v8a" "bundle" "arm64-v8a" "120-640dpi"  "Android 9.0+"
	npatch "instagram-arm64-v8a" "NexAlloy-nonroot-release*.apk" "gnadgnaoh" "--injectdex --sigbypasslv 3"
	# Patch Thread:
	get_apk "com.instagram.barcelona" "threads-arm64-v8a" "bundle" "arm64-v8a" "320-480dpi" "Android 9.0+"
	npatch "threads-arm64-v8a" "NexAlloy-nonroot-release*.apk" "gnadgnaoh" "--injectdex --sigbypasslv 3"
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
