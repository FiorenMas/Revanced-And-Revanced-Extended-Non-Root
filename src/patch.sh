#!/bin/bash
set -e
source ./src/config.sh
# Set variables for Revanced
readonly revanced_name="revanced"
readonly revanced_user="revanced"
readonly revanced_patch="./patches/ytrv-patches.txt"
readonly revanced_ytversion="" # Input version supported if you need patch specific YT version.Example: "18.03.36"
# Set variables for Revanced Extended
readonly revanced_extended_name="revanced-extended"
readonly revanced_extended_user="inotia00"
readonly revanced_extended_patch="./patches/ytrve-patches.txt"
readonly revanced_extended_ytversion="" # Input version supported if you need patch specific YT version.Example: "18.07.35"
# Loop over Revanced & Revanced Extended 
for name in $revanced_name $revanced_extended_name ; do
    # Select variables based on name
    if [[ "$name" = "$revanced_name" ]]; then
        user="$revanced_user"
        patch_file="$revanced_patch"
        key="$revanced_patch_key"
        ytversion="$revanced_ytversion"
    else
        user="$revanced_extended_user"
        patch_file="$revanced_extended_patch"
        key="$revanced_extended_patch_key"
        ytversion="$revanced_extended_ytversion"
    fi  
get_patch
download_latest_release
    # Patch YouTube 
    if [[ $ytversion ]] ; then 
        dl_yt $ytversion youtube-v$ytversion.apk 
        patch_yt
    else
        get_support_ytversion 
        dl_yt $ytversion youtube-v$ytversion.apk
        patch_yt
    fi 
    #Patch YouTube Music 
    if [[ "$name" = "$revanced_name" ]] ; then
        get_support_ytmsversion
        dl_ytms $ytmsversion youtube-music-v$ytmsversion.apk 
        patch_msrv
     else 
        get_latest_ytmsversion 
        dl_ytms $ytmsversion youtube-music-v$ytmsversion.apk 
        patch_msrve
     fi
clean_cache
done
