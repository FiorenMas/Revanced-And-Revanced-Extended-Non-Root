#!/bin/bash
# Xposed build
source ./src/build/utils.sh

NPatch_dl(){
	dl_gh "NPatch" "7723mod" "latest"
	ln -sf jar-v*.jar npatch.jar
}

build_1() {
	# Patch Revenge:
	dl_gh "revenge-xposed" "revenge-mod" "latest"
	NPatch_dl
	get_apk "com.discord" "discord" "bundle"
	npatch "discord" "app-release" "revenge"
}

build_2() {
	NPatch_dl
	dl_gh "NexAlloy" "gnadgnaoh" "v3.0"
	# Patch Meta:
	# --injectdex   : Meta app uses isolated render/service processes; injecting the
	#                 loader dex directly ensures the hook fires in all of them.
	# --sigbypasslv 3 : Level 3 (Extreme) replaces AppComponentFactory so the OS
	#                 reports the original signature even to isolated processes.
	version="564.0.0.48.74"
	get_apk "com.facebook.katana" "facebook-arm64-v8a" "bundle" "arm64-v8a" " nodpi" "Android 11+"
	npatch "facebook-arm64-v8a" "NexAlloy-nonroot-release*.apk" "gnadgnaoh" \
		--injectdex --sigbypasslv 3
	# Patch Messenger:
	get_apk "com.facebook.orca" "messenger-arm64-v8a" "apk" "arm64-v8a" "nodpi" "Android 9.0+"
	npatch "messenger-arm64-v8a" "NexAlloy-nonroot-release*.apk" "gnadgnaoh" \
		--injectdex --sigbypasslv 3
	# Patch Instagram:
	get_apk "com.instagram.android" "instagram-arm64-v8a" "bundle" "arm64-v8a" "120-640dpi" "Android 9.0+"
	npatch "instagram-arm64-v8a" "NexAlloy-nonroot-release*.apk" "gnadgnaoh" \
		--injectdex --sigbypasslv 3
	# Patch Thread:
	get_apk "com.instagram.barcelona" "threads-arm64-v8a" "bundle" "arm64-v8a" "320-480dpi" "Android 9.0+"
	npatch "threads-arm64-v8a" "NexAlloy-nonroot-release*.apk" "gnadgnaoh" \
		--injectdex --sigbypasslv 3
}

case "$1" in
    1)
        build_1
        ;;
    2)
        build_2
        ;;
esac
