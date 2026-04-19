#!/bin/bash
# Paresh build
source ./src/build/utils.sh
# Download requirements
paresh_dl(){
	dl_gh "morphe-cli" "MorpheApp" "latest"
	dl_gh "paresh-patches" "Paresh-Maheshwari" "latest"
}
1() {
	paresh_dl
	# Patch Truecaller:
	# Arm64-v8a
	get_patches_key "truecaller-paresh"
	get_apk "com.truecaller" "truecaller-arm64-v8a" "truecaller-caller-id-block" "true-software-scandinavia-ab/truecaller-caller-id-block/truecaller-trusted-caller-id" "Bundle"
	patch "truecaller-arm64-v8a" "paresh" "morphe"
	# Patch Eyecon Caller ID & Spam Block:
	# Arm64-v8a
	get_patches_key "eyecon-caller-paresh"
	get_apk "com.eyecon.global" "eyecon-caller-arm64-v8a" "eyecon-caller-id-spam-block" "eyecon-phone-dialer-contacts/eyecon-caller-id-spam-block/eyecon-caller-id-spam-block" "Bundle"
	patch "eyecon-caller-arm64-v8a" "paresh" "morphe"
}
2() {
	paresh_dl
	# Patch Telegram (web version)
	get_patches_key "telegram-paresh"
	get_apk "org.telegram.messenger" "telegram-web-version" "telegram-web-version" "telegram-fz-llc/telegram-web-version/telegram-web-version"
	patch "telegram-web-version" "paresh" "morphe"
}
case "$1" in
    1)
        1
        ;;
    2)
        2
        ;;
esac
