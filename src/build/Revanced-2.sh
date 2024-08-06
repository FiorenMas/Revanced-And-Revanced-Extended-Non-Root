#!/bin/bash
# Revanced build
source ./src/build/utils.sh

#################################################

# Download requirements
dl_gh "revanced-patches revanced-cli revanced-integrations" "revanced" "latest"

#################################################

# Patch Twitch:
get_patches_key "twitch"
get_apk "tv.twitch.android.app" "twitch" "twitch" "twitch-interactive-inc/twitch/twitch"
patch "twitch" "revanced"

#################################################

# Patch Reddit:
get_patches_key "reddit"
version="2024.17.0"
get_apk "com.reddit.frontpage" "reddit" "reddit" "redditinc/reddit/reddit"
patch "reddit" "revanced"

#################################################

# Patch Tiktok:
get_patches_key "tiktok"
get_apk "com.ss.android.ugc.trill" "tiktok" "tik-tok" "tiktok-pte-ltd/tik-tok/tik-tok"
patch "tiktok" "revanced"

#################################################
