#!/bin/bash
# Xposed build
source ./src/build/utils.sh

LSPatch_dl(){
	dl_gh "LSPatch" "JingMatrix" "latest"
}
1() {
	# Patch Revenge:
	dl_gh "revenge-xposed" "revenge-mod" "latest"
	LSPatch_dl
	get_apk "com.discord" "discord" "bundle"
	lspatch "discord" "app-release" "revenge"
}
2() {
	LSPatch_dl
	dl_gh "NexAlloy" "gnadgnaoh" "v1.0"
	# Patch Facebook:
	version="561.0.0.42.67"
	get_apk "com.facebook.katana" "facebook-arm64-v8a" "bundle" "arm64-v8a" "nodpi" "Android 11+"
	lspatch "facebook-arm64-v8a" "NexAlloy-nonroot-release*.apk" "gnadgnaoh"
	# Patch Messenger:
	get_apk "com.facebook.orca" "messenger-arm64-v8a" "apk" "arm64-v8a" "nodpi" "Android 9.0+"
	lspatch "messenger-arm64-v8a" "NexAlloy-nonroot-release*.apk" "gnadgnaoh"
	# Patch Instagram:
	get_apk "com.instagram.android" "instagram-arm64-v8a" "bundle" "arm64-v8a" "120-640dpi"  "Android 9.0+"
	lspatch "instagram-arm64-v8a" "NexAlloy-nonroot-release*.apk" "gnadgnaoh"
}
case "$1" in
    1)
        1
        ;;
    2)
        2
        ;;
esac
