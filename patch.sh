#!/bin/bash
# Config to patch Revanced and Revanced Extended
# Input YTVERSION number of version/blank to select specific/auto select YouTube version supported 

# Revanced 
cat > keywords.rv << EOF
NAME="revanced"
USER="revanced"
PATCH="patches.rv"
YTVERSION="18.03.36"
EOF

# Revanced Extended 
cat > keywords.rve << EOF
NAME="revanced-extended"
USER="inotia00"
PATCH="patches.rve"
#YTVERSION="18.07.35"
EOF

#for var in keywords.rv # Revanced
for var in keywords.rve # Revanced Extended 
#for var in keywords.rv keywords.rve # Both
do
source  $var

# Prepair patches keywords
patch_file=$PATCH

# Get line numbers where included & excluded patches start from. 
# We rely on the hardcoded messages to get the line numbers using grep
excluded_start="$(grep -n -m1 'EXCLUDE PATCHES' "$patch_file" \
| cut -d':' -f1)"
included_start="$(grep -n -m1 'INCLUDE PATCHES' "$patch_file" \
| cut -d':' -f1)"

# Get everything but hashes from between the EXCLUDE PATCH & INCLUDE PATCH line
# Note: '^[^#[:blank:]]' ignores starting hashes and/or blank characters i.e, whitespace & tab excluding newline
excluded_patches="$(tail -n +$excluded_start $patch_file \
| head -n "$(( included_start - excluded_start ))" \
| grep '^[^#[:blank:]]')"

# Get everything but hashes starting from INCLUDE PATCH line until EOF
included_patches="$(tail -n +$included_start $patch_file \
| grep '^[^#[:blank:]]')"

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


# Download resources necessary
echo -e "⏬ Prepairing $NAME resources..."

IFS=$' \t\r\n'

# Patches & json
latest_patches=$(curl -s https://api.github.com/repos/$USER/revanced-patches/releases/latest \
| jq -r '.assets[].browser_download_url') 

# Cli
latest_cli=$(curl -s https://api.github.com/repos/$USER/revanced-cli/releases/latest \
| jq -r '.assets[].browser_download_url') 

# Integrations
latest_integrations=$(curl -s https://api.github.com/repos/$USER/revanced-integrations/releases/latest \
| jq -r '.assets[].browser_download_url')

# Download all resources
for asset in $latest_patches $latest_cli $latest_integrations ; do
      curl -s -OL $asset
done

# Download YouTube APK supported
WGET_HEADER="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:111.0) Gecko/20100101 Firefox/111.0"

req() {
    wget -q -O "$2" --header="$WGET_HEADER" "$1"
}

dl_yt() {
    rm -rf $2
    echo -e "⏬ Downloading YouTube v$1..."
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

# Download specific or auto choose Youtube version
if [ $YTVERSION ] ;
  then
    dl_yt $YTVERSION youtube-v$YTVERSION.apk
    else YTVERSION=$(jq -r '.[] | select(.name == "microg-support") | .compatiblePackages[] | select(.name == "com.google.android.youtube") | .versions[-1]' patches.json)
  dl_yt $YTVERSION youtube-v$YTVERSION.apk
fi

# Patch APK
echo -e "⚙️ Patching YouTube..."
java -jar revanced-cli*.jar \
     -m revanced-integrations*.apk \
     -b revanced-patches*.jar \
     -a youtube-v$YTVERSION.apk \
     ${patches[@]} \
     --keystore=ks.keystore \
     -o yt-$NAME-v$YTVERSION.apk

# Refresh patches cache
echo -e "🧹 Clean patches cache..."
rm -f revanced-cli*.jar \
      revanced-integrations*.apk \
      revanced-patches*.jar \
      patches.json \
      options.toml \
      youtube*.apk \ 
      
unset patches      

# Finish
done
