#!/bin/bash
# Revanced build
source ./src/build/utils.sh

#################################################

# Download requirements
dl_gh "revanced-patches revanced-integrations" "revanced" "prerelease"
dl_gh "revanced-cli" "revanced" "latest"

#################################################

# Patch Instagram:
# Arm64-v8a
get_patches_key "instagram"
version="332.0.0.38.90"
get_apk "com.instagram.android" "instagram-arm64-v8a-beta" "instagram-instagram" "instagram/instagram-instagram/instagram-instagram" "arm64-v8a" "nodpi"
patch "instagram-arm64-v8a-beta" "revanced"

#################################################

# Patch Messenger:
# Arm64-v8a
get_patches_key "messenger"
get_apk "com.facebook.orca" "messenger-arm64-v8a-beta" "messenger" "facebook-2/messenger/messenger" "arm64-v8a" "nodpi"
patch "messenger-arm64-v8a-beta" "revanced"

#################################################

# Patch Twitter:
get_patches_key "twitter"
get_apk "com.twitter.android" "twitter-beta" "twitter" "x-corp/twitter/twitter"
patch "twitter-beta" "revanced"

#################################################

# Patch Twitch:
get_patches_key "twitch"
get_apk "tv.twitch.android.app" "twitch-beta" "twitch" "twitch-interactive-inc/twitch/twitch"
patch "twitch-beta" "revanced"

#################################################

# Patch Reddit:
get_patches_key "reddit"
version="2024.17.0"
get_apk "com.reddit.frontpage" "reddit-beta" "reddit" "redditinc/reddit/reddit"
patch "reddit-beta" "revanced"

#################################################

# Patch Tiktok:
get_patches_key "tiktok"
get_apk "com.ss.android.ugc.trill" "tiktok-beta" "tik-tok" "tiktok-pte-ltd/tik-tok/tik-tok"
patch "tiktok-beta" "revanced"

#################################################
