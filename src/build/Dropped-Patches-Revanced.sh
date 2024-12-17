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
get_apk "net.dinglisch.android.taskerm" "tasker" "tasker" "joaomgcd/tasker/tasker"
patch "tasker" "indrastorms"

#################################################

#Patch Nova Launcher:
get_patches_key "nova-launcher-indrastorms"
get_apk "com.teslacoilsw.launcher" "nova-launcher" "nova-launcher" "teslacoil-software/nova-launcher/nova-launcher"
patch "nova-launcher" "indrastorms"

#################################################

#Patch FX File Explorer:
get_patches_key "fx-file-explorer-indrastorms"
get_apk "nextapp.fx" "fx-file-explorer" "fx-file-explorer" "nextapp-inc/fx-file-explorer/fx-file-explorer"
patch "fx-file-explorer" "indrastorms"

#################################################