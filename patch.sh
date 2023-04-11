#!/bin/bash
set -e
# Set variables for Revanced
readonly revanced_name="revanced"
readonly revanced_user="revanced"
readonly revanced_patch="patches.rv"
readonly revanced_ytversion="" # Input version supported if you need patch specific YT version.Example: "18.03.36"
# Set variables for Revanced Extended
readonly revanced_extended_name="revanced-extended"
readonly revanced_extended_user="inotia00"
readonly revanced_extended_patch="patches.rve"
readonly revanced_extended_ytversion="" # Input version supported if you need patch specific YT version.Example: "18.07.35"
# Function prepare patches keywords
get_patch() {
    local excluded_start=$(grep -n -m1 'EXCLUDE PATCHES' "$patch_file" | cut -d':' -f1)
    local included_start=$(grep -n -m1 'INCLUDE PATCHES' "$patch_file" | cut -d':' -f1)
    local excluded_patches=$(tail -n +$excluded_start $patch_file | head -n "$(( included_start - excluded_start ))"  | grep '^[^#[:blank:]]')
    local included_patches=$(tail -n +$included_start $patch_file | grep '^[^#[:blank:]]')
    local patches=()
    if [[ -n "$excluded_patches" ]]; then
        while read -r patch; do
            patches+=("-e $patch")
        done <<< "$excluded_patches"
    fi
    if [[ -n "$included_patches" ]]; then
        while read -r patch; do
            patches+=("-i $patch")
        done <<< "$included_patches"
    fi
}
# Function download latest github releases 
download_latest_release() {
    echo "⏬ Downloading $name resources..."
    for repos in revanced-patches revanced-cli revanced-integrations; do
       local url="https://api.github.com/repos/$user/$repos/releases/latest"
       curl -s "$url" | jq -r '.assets[].browser_download_url' | xargs -n 1 curl -O -s -L
   done
}
# Function download YouTube apk from APKmirror
req() {
    curl -sSL -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:111.0) Gecko/20100101 Firefox/111.0" "$1" -o "$2"
}
dl_yt() {
  rm -rf $2
  echo "⏬ Downloading YouTube $1..."
  url="https://www.apkmirror.com/apk/google-inc/youtube/youtube-${1//./-}-release/"
  url="$url$(req "$url" - | grep Variant -A50 | grep ">APK<" -A2 | grep android-apk-download | sed "s#.*-release/##g;s#/\#.*##g")"
  url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
  url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
  req "$url" "$2"
}
# Function Patch APK
patch_apk() {
echo "⚙️ Patching YouTube..."
java -jar revanced-cli*.jar \
     -m revanced-integrations*.apk \
     -b revanced-patches*.jar \
     -a youtube-v$ytversion.apk \
     ${patches[@]} \
     --keystore=ks.keystore \
     -o yt-$name.apk
}
# Function clean caches to new build
clean_cache() {
echo "🧹 Clean caches..."
rm -f revanced-cli*.jar \
      revanced-integrations*.apk \
      revanced-patches*.jar \
      patches.json \
      options.toml \
      youtube*.apk \ 
}
# Loop over Revanced & Revanced Extended 
for name in $revanced_name $revanced_extended_name ; do
    # Select variables based on name
    if [[ "$name" = "$revanced_name" ]]; then
        user="$revanced_user"
        patch_file="$revanced_patch"
        ytversion="$revanced_ytversion"
    else
        user="$revanced_extended_user"
        patch_file="$revanced_extended_patch"
        ytversion="$revanced_extended_ytversion"
    fi  
get_patch
download_latest_release
if [[ $ytversion ]] ;
  then dl_yt $ytversion youtube-v$ytversion.apk 
else ytversion=$(jq -r '.[] | select(.name == "microg-support") | .compatiblePackages[] | select(.name == "com.google.android.youtube") | .versions[-1]' patches.json) 
  dl_yt $ytversion youtube-v$ytversion.apk
fi 
patch_apk
clean_cache
done
