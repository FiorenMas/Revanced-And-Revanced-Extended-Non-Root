#!/bin/bash
# Dropped Patches by indrastorms
source ./src/build/utils.sh

#################################################

# Download requirements
dl_gh "Dropped-Patches" "indrastorms" "v1.4.2"
dl_gh "revanced-integrations" "revanced" "v1.8.0"
dl_gh "revanced-cli" "revanced" "v4.6.0"

#################################################

# Patch Tasker:
get_patches_key "tasker-indrastorms"
req "https://tasker.joaoapps.com/releases/playstore/Tasker.6.0.10.apk" "tasker.apk" #Dev homepage, only this version can patch.
patch "tasker" "indrastorms"

#################################################

#Patch Nova Launcher:
get_patches_key "nova-launcher-indrastorms"
get_apkpure "com.teslacoilsw.launcher" "nova-launcher" "nova-launcher/com.teslacoilsw.launcher"
patch "nova-launcher" "indrastorms"

#################################################

#Patch FX File Explorer:
get_patches_key "fx-file-explorer-indrastorms"
get_apk "nextapp.fx" "fx-file-explorer" "fx-file-explorer" "nextapp-inc/fx-file-explorer/fx-file-explorer"
patch "fx-file-explorer" "indrastorms"

#################################################
