#!/bin/bash
# hoo-dles build
source ./src/build/utils.sh
# Download requirements
hoo-dles_dl(){
	dl_gh "morphe-cli" "MorpheApp" "latest"
	dl_gh "morphe-patches" "hoo-dles" "latest"
}
1() {
	hoo-dles_dl
	# Patch Amazon Prime Video:
	# Arm64-v8a
	get_patches_key "prime-video-hoo-dles"
	version="3.0.447"
	get_apk "com.amazon.avod.thirdpartyclient" "prime-video-arm64-v8a" "apk" "arm64-v8a" "nodpi" "Android 9.0+"
	patch "prime-video-arm64-v8a" "hoo-dles" "morphe"
	# Patch Adguard
	get_patches_key "adguard-hoo-dles"
	get_apk "com.adguard.android" "adguard" "apk"
	patch "adguard" "hoo-dles" "morphe"
}
2() {
	hoo-dles_dl
	# Patch Duolingo
	get_patches_key "duolingo-hoo-dles"
	get_apk "com.duolingo" "duolingo" "bundle" "universal" "120-640dpi"
	patch "duolingo" "hoo-dles" "morphe"
	# Patch Proton VPN
	get_patches_key "Proton-VPN-hoo-dles"
	get_apk "ch.protonvpn.android" "protonvpn" "bundle" "universal" "120-640dpi" "Android 8.0+"
	patch "protonvpn" "hoo-dles" "morphe"
}
3() {
	hoo-dles_dl
	# Patch Smart Launcher
	get_patches_key "smart-launcher-hoo-dles"
	version="6.6.build.008"
	get_apk "ginlemon.flowerfree" "smart-launcher" "apk"
	patch "smart-launcher" "hoo-dles" "morphe"
	# Patch SoundCloud
	get_patches_key "soundcloud-hoo-dles"
	get_apk "com.soundcloud.android" "soundcloud" "bundle" "universal" "nodpi" "Android 12L+"
	patch "soundcloud" "hoo-dles" "morphe"
}
4() {
	hoo-dles_dl
	# Patch Solid Explorer
	get_patches_key "solid-explorer-hoo-dles"
	get_apk "pl.solidexplorer2" "solid-explorer" "bundle"
	patch "solid-explorer" "hoo-dles" "morphe"
	# WPS Office
	get_patches_key "WPS-Office-hoo-dles"
	get_apk "cn.wps.moffice_eng" "wps-office" "apk"
	patch "wps-office" "hoo-dles" "morphe"
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
