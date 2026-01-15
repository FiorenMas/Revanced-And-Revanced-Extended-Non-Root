#!/bin/bash
# ReVancedXposed build
source ./src/build/utils.sh
#################################################
# Download requirements
j="i"
dl_gh "ReVancedXposed_Spot"$j"fy" "chsbuffer" "latest"
dl_gh "LSPatch" "JingMatrix" "latest"
#################################################

# Patch Spotjfy:
get_apkpure "com.spot"$j"fy.music" "spotjfy" "spot"$j"fy-music-and-podcasts-for-android/com.spot"$j"fy.music"
green_log "[+] Patching apk file..."
java -jar lspatch.jar ./download/spotjfy.apk -k ./src/fiorenmas.ks fiorenmas fiorenmas fiorenmas -m ReVancedXposed*.apk -o ./release/
mv ./release/spotjfy-*-lspatched.apk ./release/spotjfy-ReVancedXposed.apk