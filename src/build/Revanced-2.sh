#!/bin/bash
# Revanced build
source ./src/build/utils.sh

#################################################

# Download requirements
dl_gh "revanced-patches revanced-cli revanced-integrations" "revanced" "latest"

#################################################

# Patch Instagram:
# Arm64-v8a
get_patches_key "instagram"
get_ver "Hide timeline ads" "com.instagram.android"
get_apk "instagram-arm64-v8a" "instagram-instagram" "instagram/instagram-instagram/instagram-instagram" "arm64-v8a" "nodpi"
patch "instagram-arm64-v8a" "revanced"

#################################################

# Patch Messenger:
# Arm64-v8a
get_patches_key "messenger"
get_apk "messenger-arm64-v8a" "messenger" "facebook-2/messenger/messenger" "arm64-v8a" "nodpi"
patch "messenger-arm64-v8a" "revanced"

#################################################

# Patch Twitter:
get_patches_key "twitter"
get_apk "twitter" "twitter" "x-corp/twitter/twitter"
patch "twitter" "revanced"

#################################################

# Patch Twitch:
get_patches_key "twitch"
get_ver "Block audio ads" "tv.twitch.android.app"
get_apk "twitch" "twitch" "twitch-interactive-inc/twitch/twitch"
patch "twitch" "revanced"

#################################################

# Patch Reddit:
get_patches_key "reddit"
version="2024.17.0"
get_apk "reddit" "reddit" "redditinc/reddit/reddit"
patch "reddit" "revanced"

#################################################

# Patch Tiktok:
get_patches_key "tiktok"
get_ver "Feed filter" "com.ss.android.ugc.trill"
get_apk "tiktok" "tik-tok" "tiktok-pte-ltd/tik-tok/tik-tok"
patch "tiktok" "revanced"

#################################################
