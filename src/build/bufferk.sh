#!/bin/bash
# hoo-dles build
source ./src/build/utils.sh
# Download requirements
bufferk_dl(){
	dl_gh "morphe-desktop" "MorpheApp" "latest"
	dl_gh "morphe-patches" "bufferk" "latest"
}
1() {
	bufferk_dl
	# Patch Brave Browser
	#Arm64-v8a
	get_patches_key "brave-browser-bufferk"
	get_apk "com.brave.browser" "brave-browser-arm64-v8a" "bundle" "arm64-v8a"
	patch "brave-browser-arm64-v8a" "bufferk"
}
2() {
	bufferk_dl
	# Patch Truecaller:
	# Arm64-v8a
	get_patches_key "truecaller-bufferk"
	get_apk "com.truecaller" "truecaller-arm64-v8a" "bundle"
	patch "truecaller-arm64-v8a" "bufferk"
	# Patch Medium
	#get_patches_key "medium-bufferk"
	#near_version="1"
	#get_apk "com.medium.reader" "medium" "apk"
	#patch "medium" "bufferk"
}
case "$1" in
    1)
        1
        ;;
    2)
        2
        ;;
esac
