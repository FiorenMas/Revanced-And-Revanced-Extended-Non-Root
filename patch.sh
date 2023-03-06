#!/bin/bash
# File containing all patches and YouTube version
# source patch-rv.txt
# source patch-rve.txt
for var in Revanced.txt Revanced-Extended.txt
do
source $var

patch_file=${PATCH}
# Get line numbers where included & excluded patches start from. 
# We rely on the hardcoded messages to get the line numbers using grep
excluded_start="$(grep -n -m1 'EXCLUDE PATCHES' "$patch_file" | cut -d':' -f1)"
included_start="$(grep -n -m1 'INCLUDE PATCHES' "$patch_file" | cut -d':' -f1)"

# Get everything but hashes from between the EXCLUDE PATCH & INCLUDE PATCH line
# Note: '^[^#[:blank:]]' ignores starting hashes and/or blank characters i.e, whitespace & tab excluding newline
excluded_patches="$(tail -n +$excluded_start $patch_file | head -n "$(( included_start - excluded_start ))" | grep '^[^#[:blank:]]')"

# Get everything but hashes starting from INCLUDE PATCH line until EOF
included_patches="$(tail -n +$included_start $patch_file | grep '^[^#[:blank:]]')"

# Array for storing patches
declare -a patches

# Function for populating patches array, using a function here reduces redundancy & satisfies DRY principals
populate_patches() {
    # Note: <<< defines a 'here-string'. Meaning, it allows reading from variables just like from a file
    while read -r patch; do
        patches+=("$1 $patch")
    done <<< "$2"
}

# If the variables are NOT empty, call populate_patches with proper arguments
[[ ! -z "$excluded_patches" ]] && populate_patches "-e" "$excluded_patches"
[[ ! -z "$included_patches" ]] && populate_patches "-i" "$included_patches"

# Begin
WGET_HEADER="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101 Firefox/102.0"
DATE=$(date +%y%m%d)
DRAFT=false
if [ x${1} == xtest ]; then DRAFT=true; fi

req() {
    wget -q -O "$2" --header="$WGET_HEADER" "$1"
}

get_latestytversion() {
    url="https://www.apkmirror.com/apk/google-inc/youtube/"
    YTVERSION=$(req "$url" - | grep "All version" -A200 | grep app_release | sed 's:.*/youtube-::g;s:-release/.*::g;s:-:.:g' | sort -r | head -1)
    echo "Latest Youtube Version: $YTVERSION"
}

dl_yt() {
    rm -rf $2
    echo "🚘 Downloading YouTube v$1"
    url="https://www.apkmirror.com/apk/google-inc/youtube/youtube-${1//./-}-release/"
    url="$url$(req "$url" - | grep Variant -A50 | grep ">APK<" -A2 | grep android-apk-download | sed "s#.*-release/##g;s#/\#.*##g")"
    url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
    url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
    req "$url" "$2"
}
# Fetch latest official supported YT versions
curl -s https://api.github.com/repos/${USER}/revanced-patches/releases/latest \
| grep "browser_download_url.*json" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -
mv patches.json ${NAME}-patches.json
YTVERSION=$(jq -r '.[] | select(.name == "microg-support") | .compatiblePackages[] | select(.name == "com.google.android.youtube") | .versions[-1]' ${NAME}-patches.json)
rm -rf ${NAME}-patches.json

# Download Youtube
dl_yt $YTVERSION youtube-v${YTVERSION}.apk

# Get patches 
echo "⏭️ Prepairing ${NAME} patches..."

# Revanced-patches
curl -s https://api.github.com/repos/${USER}/revanced-patches/releases/latest \
| grep "browser_download_url.*jar" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -
mv revanced-patches*.jar ${NAME}-patches.jar

# Revanced CLI
curl -s https://api.github.com/repos/${USER}/revanced-cli/releases/latest \
| grep "browser_download_url.*jar" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -
mv revanced-cli*.jar ${NAME}-cli.jar

# ReVanced Integrations
curl -s https://api.github.com/repos/${USER}/revanced-integrations/releases/latest \
| grep "browser_download_url.*apk" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -
mv revanced-integrations*.apk ${NAME}-integrations.apk

# Patch revanced and revanced extended
echo "⏭️ Patching YouTube..."
java -jar ${NAME}-cli.jar -m ${NAME}-integrations.apk -b ${NAME}-patches.jar \
   ${patches[@]} \
    -a youtube-v${YTVERSION}.apk -o ${NAME}.apk

# Find and select apksigner binary
echo "⏭️ Signing ${NAME}-v${YTVERSION}..."
apksigner="$(find $ANDROID_SDK_ROOT/build-tools -name apksigner | sort -r | head -n 1)"

# Sign apks (https://github.com/tytydraco/public-keystore)
${apksigner} sign --ks public.jks --ks-key-alias public --ks-pass pass:public --key-pass pass:public --in ./${NAME}.apk --out ./yt-${NAME}.apk

# Refresh patches cache
echo "⏭️ Clean patches cache..."
rm -f *-cli.jar *-integrations.apk *-patches.jar 

# Finish
done
