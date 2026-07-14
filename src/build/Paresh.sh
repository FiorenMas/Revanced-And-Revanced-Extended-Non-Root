#!/bin/bash
# Paresh build
source ./src/build/utils.sh
# Download requirements
paresh_dl(){
	dl_gh "morphe-desktop" "MorpheApp" "latest"
	dl_gl "paresh-patches" "Paresh-Maheshwari" "latest"
}
1() {
	paresh_dl
	# Patch Truecaller:
	# Arm64-v8a
	get_patches_key "truecaller-paresh"
	get_apk "com.truecaller" "truecaller-arm64-v8a" "bundle"
	patch "truecaller-arm64-v8a" "paresh"
	# Patch Eyecon Caller ID & Spam Block:
	# Arm64-v8a
	get_patches_key "eyecon-caller-paresh"
	get_apk "com.eyecon.global" "eyecon-caller-arm64-v8a" "bundle"
	patch "eyecon-caller-arm64-v8a" "paresh"
}
2() {
	paresh_dl
	# Patch Telegram (web version)
	get_patches_key "telegram-paresh"
	get_apk "org.telegram.messenger" "telegram-web-version" "apk"
	patch "telegram-web-version" "paresh"
}
case "$1" in
    1)
        1
        ;;
    2)
        2
        ;;
esac
