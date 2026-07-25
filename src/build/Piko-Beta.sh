#!/bin/bash
# Twitter Piko
source src/build/utils.sh
piko_dl(){
    dl_gh "morphe-desktop" "MorpheApp" "latest"
    dl_gh "piko" "crimera" "prerelease"
}

1() {
    piko_dl
    # Patch Twitter Piko:
    get_patches_key "twitter-piko"
    get_apk "com.twitter.android" "twitter-beta" "bundle"
    patch "twitter-beta" "piko"
}
2() {
    piko_dl
    # Patch Instagram
    get_patches_key "instagram-piko"
    get_apk "com.instagram.android" "instagram-beta-arm64-v8a" "bundle" "arm64-v8a" "120-640dpi"  "Android 9.0+"
    patch "instagram-beta-arm64-v8a" "piko"
}
case "$1" in
    1)
        1
        ;;
    2)
        2
        ;;
esac
