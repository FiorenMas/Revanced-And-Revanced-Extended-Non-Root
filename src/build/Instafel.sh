#!/bin/bash
# instafel build
source ./src/build/utils.sh
#################################################
# Download requirements
dl_gh "p-rel" "instafel" "latest"
java -jar ifl-patcher*.jar
#################################################

# Get patches
export includePatch=$(sed 's/\r$//' src/patches/instagram_instafel/patches | xargs)

# Patch Instagram:
get_apkpure "com.instagram.android" "instagram" "instagram-android/com.instagram.android" "Bundle"
green_log "[+] Decrypting apk file..."
java -jar ifl-patcher*.jar init "./download/instagram.apk"
green_log "[+] Patching apk file..."
java -jar ifl-patcher*.jar run "instagram" $includePatch
green_log "[+] Compling apk file..."
java -jar ifl-patcher*.jar build "instagram"
cp instagram/build/unclone.apk ./release/instagram-instafel.apk
cp instagram/build/clone.apk ./release/instagram-clone-instafel.apk