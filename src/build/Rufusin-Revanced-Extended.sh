#!/bin/bash
# Revanced Extended forked by Rufusin build
source src/build/utils.sh

#################################################

# Download requirements
dl_gh "revanced-patches revanced-integrations" "rufusin" "latest"
dl_gh "revanced-cli" "revanced" "latest"

#################################################

# Patch YouTube Rufusin:
get_patches_key "youtube-rve-rufusin"
get_apk "com.google.android.youtube" "youtube" "youtube" "google-inc/youtube/youtube"
patch "youtube" "rufusin"

#################################################

rm -f revanced-cli* revanced-patches*.jar *.json
dl_gh "revanced-cli" "inotia00" "latest"
dl_gh "revanced-patches" "inotia00" "latest"
# Split architecture Youtube:
for i in {0..3}; do
    split_arch "youtube-rufusin" "youtube-${archs[i]}-rufusin" "$(gen_rip_libs ${libs[i]})"
done

#################################################