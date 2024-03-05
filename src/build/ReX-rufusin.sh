#!/bin/bash
# ReX forked by rufusin build
source src/build/utils.sh

#################################################

# Download requirements
dl_gh " revanced-patches revanced-integrations" "rufusin" "latest"
dl_gh "revanced-cli" "inotia00" "latest"

#################################################

# Patch YouTube ReX rufusin:
get_patches_key "youtube-ReX-rufusin"
get_ver "Hide general ads" "com.google.android.youtube"
get_apk "youtube" "youtube" "google-inc/youtube/youtube"
patch "youtube" "ReX-rufusin" "inotia"


#################################################

rm -f revanced-cli*
dl_gh "revanced-cli" "FiorenMas" "latest"
# Split architecture Youtube:
get_patches_key "youtube-ReX-rufusin"
for i in {0..3}; do
    split_arch "youtube" "youtube-${archs[i]}-ReX-rufusin" "$(gen_rip_libs ${libs[i]})"
done

#################################################