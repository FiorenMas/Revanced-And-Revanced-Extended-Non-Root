#!/bin/bash
# Twitter Piko
source src/build/utils.sh
piko_dl(){
    dl_gh "morphe-cli" "MorpheApp" "latest"
    dl_gh "piko" "crimera" "prerelease"
}

1() {
    piko_dl
    # Patch Twitter Piko:
    get_patches_key "twitter-piko"
    telegram_dl "https://t.me/xriprepo" "10" "*.apk" "twitter-beta.apk" #https://github.com/crimera/piko/issues/1146#issuecomment-4469171783
    patch "twitter-beta" "piko" "morphe"
}
2() {
    piko_dl
    # Patch Instagram
    get_patches_key "instagram-piko"
    get_apk "com.instagram.android" "instagram-beta-arm64-v8a" "bundle" "arm64-v8a" "120-640dpi"  "Android 9.0+"
    patch "instagram-beta-arm64-v8a" "piko" "morphe"
}
case "$1" in
    1)
        1
        ;;
    2)
        2
        ;;
esac
