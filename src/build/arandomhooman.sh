#!/bin/bash
# hoo-dles build
source ./src/build/utils.sh
# Download requirements
arandomhooman_dl(){
	dl_gh "morphe-desktop" "MorpheApp" "latest"
	dl_gh "hoomans-morphe-patches" "arandomhooman" "latest"
}
1() {
	arandomhooman_dl
	# Patch Twitch
	get_patches_key "twitch-arandomhooman"
	get_apk "tv.twitch.android.app" "twitch" "bundle"
	patch "twitch" "arandomhooman"
	# Patch Tumblr
	get_patches_key "tumblr-arandomhooman"
	get_apk "com.tumblr" "tumblr" "bundle"
	patch "tumblr" "arandomhooman"
}
2() {
	arandomhooman_dl
	# Battery Guru
	get_patches_key "battery-guru-arandomhooman"
	get_apk "com.paget96.batteryguru" "battery-guru" "apk"
	patch "battery-guru" "arandomhooman"
}
case "$1" in
    1)
        1
        ;;
    2)
        2
        ;;
esac
