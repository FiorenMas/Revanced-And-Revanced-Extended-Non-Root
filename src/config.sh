#!/bin/bash
# Function prepare patches keywords
get_patch() {
    local excluded_start=$(grep -n -m1 'EXCLUDE PATCHES' "$patch_file" | cut -d':' -f1)
    local included_start=$(grep -n -m1 'INCLUDE PATCHES' "$patch_file" | cut -d':' -f1)
    local excluded_patches=$(tail -n +$excluded_start $patch_file | head -n "$(( included_start - excluded_start ))"  | grep '^[^#[:blank:]]')
    local included_patches=$(tail -n +$included_start $patch_file | grep '^[^#[:blank:]]')
    patches=()
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
    echo "🔽 Downloading $name resources"
    for repo in revanced-patches revanced-cli revanced-integrations; do
        local url="https://api.github.com/repos/$user/$repo/releases/latest"
        echo "🔍 Searching for download link at $url"
        curl -s "$url" | jq -r '.assets[] | "\(.name) \(.browser_download_url)"' | while read name download_url; do
            echo "📥 Downloading $name from $download_url"
            curl -O -s -L "$download_url"
            echo "✅ Download $name complete!"
        done
    done
}
# Function download YouTube and YouTube Music apk from APKmirror
req() {
    curl -sSL -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:111.0) Gecko/20100101 Firefox/111.0" "$1" -o "$2"
}
dl_yt() {
    rm -rf $2
        echo "🔽 Downloading YouTube version $1"
    url="https://www.apkmirror.com/apk/google-inc/youtube/youtube-${1//./-}-release/"
        echo "🔍 Searching for download link at $url"
    url="$url$(req "$url" - | grep Variant -A50 | grep ">APK<" -A2 | grep android-apk-download | sed "s#.*-release/##g;s#/\#.*##g")"
    url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
    url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
        echo "📥 Downloading from $url"
    if req "$url" "$2" ; then
        echo "✅ Download complete!"
    else 
        echo "❌ Download failed."
    fi
}
dl_ytms() {
    rm -rf $2
        echo "🔽 Downloading YouTube Music version $1"
    url="https://www.apkmirror.com/apk/google-inc/youtube/youtube-music-${1//./-}-release/"
        echo "🔍 Searching for download link at $url"
    url="$url$(req "$url" - | grep arm64 -A30 | grep youtube-music | head -1 | sed "s#.*-release/##g;s#/\".*##g")"
    url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
    url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
        echo "📥 Downloading from $url"
    if req "$url" "$2" ; then
        echo "✅ Download complete!"
    else
        echo "❌ Download failed."
    fi
}
# Function fletch latest supported version can patch
get_support_ytversion() {
    if [[ "$name" = "$revanced_name" ]] ; then
        ytversion=$(jq -r '.[] | select(.name == "video-ads") | .compatiblePackages[] | select(.name == "com.google.android.youtube") | .versions[-1]' patches.json) 
        echo "✅️ Found YouTube version: $ytversion"
    else 
        ytversion=$(jq -r '.[] | select(.name == "hide-general-ads") | .compatiblePackages[] | select(.name == "com.google.android.youtube") | .versions[-1]' patches.json) 
        echo "✅️ Found YouTube version: $ytversion"
    fi
}
get_support_ytmsversion() {
    ytmsversion=$(jq -r '.[] | select(.name == "hide-get-premium") | .compatiblePackages[] | select(.name == "com.google.android.apps.youtube.music") | .versions[-1]' patches.json)
    echo "✅️ Found YouTube Music version: $ytmsversion"
}
get_latest_ytmsversion() {
    url="https://www.apkmirror.com/apk/google-inc/youtube-music/"
    ytmsversion=$(req "$url" - | grep "All version" -A200 | grep app_release | sed 's:.*/youtube-music-::g;s:-release/.*::g;s:-:.:g' | sort -r | head -1)
    echo "✅️ Found YouTube Music version: $ytmsversion"
}
# Function Patch APK
patch_yt() {
    if [ -f "youtube-v$ytversion.apk" ]; then
        echo "⚙️ Patching YouTube"
        java -jar revanced-cli*.jar -m revanced-integrations*.apk -b revanced-patches*.jar -a youtube-v$ytversion.apk ${patches[@]} --keystore=ks.keystore -o yt-$name.apk
        echo "✅ Patch Complete!"
    else
        echo "❌ YouTube APK not found, skipping patching"
    fi
}
patch_msrv() {
    if [ -f "youtube-music-v$ytmsversion.apk" ]; then
        echo "⚙️ Patching YouTube Music"
        java -jar revanced-cli*.jar -m revanced-integrations*.apk -b revanced-patches*.jar -a youtube-music-v$ytmsversion.apk --keystore=ks.keystore -o ytms-$name.apk
        echo "✅ Patch Complete!"
    else
        echo "❌ YouTube Music APK not found, skipping patching"
    fi
}
patch_msrve() {
    if [ -f "youtube-music-v$ytmsversion.apk" ]; then
        echo "⚙️ Patching YouTube Music"
        java -jar revanced-cli*.jar -m revanced-integrations*.apk -b revanced-patches*.jar -a youtube-music-v$ytmsversion.apk -e custom-branding-music-afn-red --keystore=ks.keystore -o ytms-$name.apk
        echo "✅ Patch Complete!"
    else
        echo "❌ YouTube Music APK not found, skipping patching"
    fi
}
# Function clean caches to new build
clean_cache() {
    echo "🧹 Clean cache"
    rm -f revanced-cli*.jar revanced-integrations*.apk revanced-patches*.jar patches.json options.toml youtube*.apk
}
