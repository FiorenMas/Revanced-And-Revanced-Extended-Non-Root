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
version="332.0.0.38.90"
get_apk "com.instagram.android" "instagram-arm64-v8a" "instagram-instagram" "instagram/instagram-instagram/instagram-instagram" "arm64-v8a" "nodpi"
patch "instagram-arm64-v8a" "revanced"

#################################################

# Patch Messenger:
# Arm64-v8a
get_patches_key "messenger"
get_apk "com.facebook.orca" "messenger-arm64-v8a" "messenger" "facebook-2/messenger/messenger" "arm64-v8a" "nodpi"
patch "messenger-arm64-v8a" "revanced"

#################################################

# Patch Twitter:
get_patches_key "twitter"
get_apk "com.twitter.android" "twitter" "twitter" "x-corp/twitter/twitter"
patch "twitter" "revanced"

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
