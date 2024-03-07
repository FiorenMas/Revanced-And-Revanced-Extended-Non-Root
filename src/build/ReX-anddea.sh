#!/bin/bash
# ReX forked by anddea build
source src/build/utils.sh

#################################################

# Download requirements
dl_gh " revanced-patches revanced-integrations" "anddea" "latest"
dl_gh "revanced-cli" "inotia00" "latest"

#################################################

# Patch YouTube ReX anddea:
get_patches_key "youtube-ReX-anddea"
get_ver "Hide general ads" "com.google.android.youtube"
get_apk "youtube" "youtube" "google-inc/youtube/youtube"
patch "youtube" "ReX-anddea" "inotia"


#################################################

rm -f revanced-cli*
dl_gh "revanced-cli" "FiorenMas" "latest"
# Split architecture Youtube:
get_patches_key "youtube-ReX-anddea"
for i in {0..3}; do
    split_arch "youtube" "youtube-${archs[i]}-ReX-anddea" "$(gen_rip_libs ${libs[i]})"
done

#################################################