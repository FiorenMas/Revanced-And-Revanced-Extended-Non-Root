#!/bin/bash
# Input *ytversion number/blank(or # before) to set specific/auto choose YouTube version

# Set variables for Revanced
revanced_name="revanced"
revanced_user="revanced"
revanced_patch="patches.rv"
revanced_ytversion="" # Input version supported.Exp: 18.03.36

# Set variables for Revanced Extended
revanced_extended_name="revanced-extended"
revanced_extended_user="inotia00"
revanced_extended_patch="patches.rve"
revanced_extended_ytversion="" # Input version supported.Exp: 18.07.35

# Function prepare patches keywords
get_patch() {
    excluded_start=$(grep -n -m1 'EXCLUDE PATCHES' "$patch_file" \
    | cut -d':' -f1)
    included_start=$(grep -n -m1 'INCLUDE PATCHES' "$patch_file" \
    | cut -d':' -f1)
    excluded_patches=$(tail -n +$excluded_start $patch_file \
    | head -n "$(( included_start - excluded_start ))" \
    | grep '^[^#[:blank:]]')
    included_patches=$(tail -n +$included_start $patch_file \
    | grep '^[^#[:blank:]]')
    patches=()
    if [ -n "$excluded_patches" ]; then
        while read -r patch; do
            patches+=("-e $patch")
        done <<< "$excluded_patches"
    fi
    if [ -n "$included_patches" ]; then
        while read -r patch; do
            patches+=("-i $patch")
        done <<< "$included_patches"
    fi
declare -a patches 
}
# Function download latest github releases 
urls_res() {
wget -q -O - "https://api.github.com/repos/$user/revanced-patches/releases/latest" \
| jq -r '.assets[].browser_download_url'  
wget -q -O - "https://api.github.com/repos/$user/revanced-cli/releases/latest" \
| jq -r '.assets[].browser_download_url'  
wget -q -O - "https://api.github.com/repos/$user/revanced-integrations/releases/latest" \
| jq -r '.assets[].browser_download_url'  
}

# Function download YouTube apk from APKmirror
WGET_HEADER="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:111.0) Gecko/20100101 Firefox/111.0"

req() {
    wget -q -O "$2" --header="$WGET_HEADER" "$1"
}

dl_yt() {
    rm -rf $2
    url="https://www.apkmirror.com/apk/google-inc/youtube/youtube-${1//./-}-release/"
    url="$url$(req "$url" - \
    | grep Variant -A50 \
    | grep ">APK<" -A2 \
    | grep android-apk-download \
    | sed "s#.*-release/##g;s#/\#.*##g")"
    url="https://www.apkmirror.com$(req "$url" - \
    | tr '\n' ' ' \
    | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
    url="https://www.apkmirror.com$(req "$url" - \
    | tr '\n' ' ' \
    | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
    req "$url" "$2"
}
# Function Patch APK
patch_apk() {
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
rm -f revanced-cli*.jar \
      revanced-integrations*.apk \
      revanced-patches*.jar \
      patches.json \
      options.toml \
      youtube*.apk \ 
}
# Function patch Revanced, Revanced Extended 
for name in $revanced_name $revanced_extended_name ; do
    # Select variables based on name
    if [ "$name" = "$revanced_name" ]; then
        user="$revanced_user"
        patch_file="$revanced_patch"
        ytversion="$revanced_ytversion"
    else
        user="$revanced_extended_user"
        patch_file="$revanced_extended_patch"
        ytversion="$revanced_extended_ytversion"
    fi
get_patch
echo "⏬ Downloading $name resources..."
urls_res | xargs wget -q -i
if [ $ytversion ] ;
  then dl_yt $ytversion youtube-v$ytversion.apk 
  echo "⏬ Downloading YouTube v$ytversion.."
else ytversion=$(jq -r '.[] | select(.name == "microg-support") | .compatiblePackages[] | select(.name == "com.google.android.youtube") | .versions[-1]' patches.json) 
  dl_yt $ytversion youtube-v$ytversion.apk
  echo "⏬ Downloading YouTube v$ytversion..."
fi
echo "⚙️ Patching YouTube..."
patch_apk
echo "🧹 Clean caches..."
clean_cache
done
