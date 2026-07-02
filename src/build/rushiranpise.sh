#!/bin/bash
# rushiranpise build
source ./src/build/utils.sh
# Download requirements
rushiranpise_dl(){
	dl_gh "morphe-cli" "MorpheApp" "latest"
	dl_gh "morphe-patches" "rushiranpise" "latest"
}
1() {
	rushiranpise_dl
	# Patch Waze:
	get_patches_key "waze-rushiranpise"
	get_apk "com.waze" "waze" "bundle" "arm64-v8a + armeabi-v7a"
	patch "waze" "rushiranpise" "morphe"
	# Patch Adguard
	get_patches_key "adguard-rushiranpise"
	get_apk "com.adguard.android" "adguard" "apk"
	patch "adguard" "rushiranpise" "morphe"
}
2() {
	rushiranpise_dl
	# Patch Psiphon
	get_patches_key "psiphon-rushiranpise"
	version="474"
	get_apk "com.psiphon3.subscription" "psiphon" "apk"
	patch "psiphon" "rushiranpise" "morphe"
	# Patch Proton VPN
	get_patches_key "Proton-VPN-rushiranpise"
	get_apk "ch.protonvpn.android" "protonvpn" "bundle" "universal" "120-640dpi" "Android 8.0+"
	patch "protonvpn" "rushiranpise" "morphe"
}
3() {
	rushiranpise_dl
	# Patch Hola VPN
	get_patches_key "Hola-VPN-rushiranpise"
	get_apk_chplay "org.hola.play" "hola-vpn"
	patch "hola-vpn" "rushiranpise" "morphe"
	# Patch Windscribe
	get_patches_key "windscribe-rushiranpise"
	get_apk "com.windscribe.vpn" "windscribe" "bundle" "universal" "160-480dpi" "Android 12L+"
	patch "windscribe" "rushiranpise" "morphe"
}
4() {
	rushiranpise_dl
	# Patch TeraBox
	get_patches_key "TeraBox-rushiranpise"
	get_apk "com.dubox.drive" "terabox" "bundle"
	patch "terabox" "rushiranpise" "morphe"
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
