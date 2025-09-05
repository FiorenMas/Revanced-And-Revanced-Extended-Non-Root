#!/bin/bash
# scrazzz build
source ./src/build/utils.sh
#################################################
# Download requirements
dl_gh "revanced-cli" "revanced" "latest"
dl_gh "my-revanced-patches" "scrazzz" "prerelease"
#################################################
# Patch Soild Explorer arm64-v8a:
get_patches_key "Soild-Explorer"
get_apk "pl.solidexplorer2" "solid-explorer-arm64-v8a" "solid-explorer-beta" "neatbytes/solid-explorer-beta/solid-explorer-file-manager" "arm64-v8a"
patch "solid-explorer-arm64-v8a" "scrazzz"
