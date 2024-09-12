#!/bin/bash
# Revanced build
source ./src/build/utils.sh

#################################################

# Download requirements
dl_gh "revanced-patches revanced-cli revanced-integrations" "revanced" "latest"

##################################################################################################

# Patch Facebook:
# Arm64-v8a
get_patches_key "facebook"
get_apk "com.facebook.katana" "facebook-arm64-v8a" "facebook" "facebook-2/facebook/facebook" "arm64-v8a" "nodpi" "Android 11+"
patch "facebook-arm64-v8a" "revanced"

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
