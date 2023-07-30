#!/bin/bash

#################################################

# Checking new patch:
checker() {
curl -sL https://api.github.com/repos/$1/releases/latest > json.txt
latest_version=$(jq -r '.name' json.txt)
curl -sL "https://api.github.com/repos/$repository/releases/latest" | jq -r '.assets[] | select(.name == "'$2'-version.txt") | .browser_download_url' | xargs curl -sLO
cur_version=$(cat $2-version.txt)
if [ "$latest_version" = "$cur_version" ]; then
	echo "Old patch, not build!"
 	rm -f ./json.txt ./$2-version.txt
	exit 0
else
	echo "New patch, building..."
	rm -f ./json.txt ./$2-version.txt
 	echo $latest_version > $2-version.txt
fi
}

#################################################

# Download the htmlq for to get apk from APKMirror
dl_htmlq() {
	req "https://github.com/mgdm/htmlq/releases/latest/download/htmlq-x86_64-linux.tar.gz" "./htmlq.tar.gz"
	tar -xf "./htmlq.tar.gz" -C "./"
	rm "./htmlq.tar.gz"
	HTMLQ="./htmlq"
}

#################################################

# Download Github assets requirement:
dl_gh() {
	for repo in $1 ; do
	wget -qO- "https://api.github.com/repos/$2/$repo/releases/$3" \
	| jq -r '.assets[] | "\(.browser_download_url) \(.name)"' \
	| while read -r url names; do
		echo "Downloading $names from $url"
		wget -q -O "$names" $url
	done
	done
echo "All assets downloaded"
}

#################################################

# Get patches list:
get_patches_key() {
	EXCLUDE_PATCHES=()
		for word in $(cat src/patches/$1/exclude-patches) ; do
			EXCLUDE_PATCHES+=("-e $word")
		done
	INCLUDE_PATCHES=()
		for word in $(cat src/patches/$1/include-patches) ; do
			INCLUDE_PATCHES+=("-i $word")
		done
}

#################################################

# Find version supported:
get_ver() {
	version=$(jq -r --arg patch_name "$1" --arg pkg_name "$2" '
	.[]
	| select(.name == $patch_name)
	| .compatiblePackages[]
	| select(.name == $pkg_name)
	| .versions[-1]
	' patches.json)
}

#################################################

# Download apks files from APKMirror:

_req() {
	if [ "$2" = - ]; then
		wget -nv -O "$2" --header="$3" "$1"
	else
		local dlp
		dlp="$(dirname "$2")/$(basename "$2")"
		if [ -f "$dlp" ]; then
			while [ -f "$dlp" ]; do sleep 1; done
			return
		fi
		wget -nv -O "$dlp" --header="$3" "$1" || return 1
	fi
}
req() { _req "$1" "$2" "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:108.0) Gecko/20100101 Firefox/108.0"; }

get_apk_vers() { 
	req "$1" - | sed -n 's;.*Version:</span><span class="infoSlide-value">\(.*\) </span>.*;\1;p'
}

get_largest_ver() {
	local max=0
	while read -r v || [ -n "$v" ]; do   		
		if [[ ${v//[!0-9]/} -gt ${max//[!0-9]/} ]]; then max=$v; fi
	done
	if [[ $max = 0 ]]; then echo ""; else echo "$max"; fi
}

dl_apk() {
	local url=$1 regexp=$2 output=$3 resp
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n "s/href=\"/@/g; s;.*${regexp}.*;\1;p")"
	echo "$url"
	url=$(req "$url" - | $HTMLQ --base https://www.apkmirror.com --attribute href "a.accent_bg.btn")
	resp=$(req "$url" - | $HTMLQ --base https://www.apkmirror.com --attribute href "span > a[rel = nofollow]")
	if [[ -z $resp ]]; then
		url=$(req "$url" - | $HTMLQ --base https://www.apkmirror.com --attribute href "a.accent_bg.btn")
		url=$(req "$url" - | $HTMLQ --base https://www.apkmirror.com --attribute href "span > a[rel = nofollow]")
	else
		url=$(req "$url" - | $HTMLQ --base https://www.apkmirror.com --attribute href "span > a[rel = nofollow]")
	fi
	req "$url" "$output"
}

get_apk() {
	if [[ -z $4 ]]; then
		url_regexp='APK</span>[^@]*@\([^#]*\)'
	else
		case $4 in
			arm64-v8a) url_regexp='arm64-v8a</div>[^@]*@\([^"]*\)' ;;
			armeabi-v7a) url_regexp='armeabi-v7a</div>[^@]*@\([^"]*\)' ;;
			x86) url_regexp='x86</div>[^@]*@\([^"]*\)' ;;
			x86_64) url_regexp='x86_64</div>[^@]*@\([^"]*\)' ;;
			*) return 1 ;;
		esac 
	fi
	export version="$version"
	if [[ -z $version ]]; then
		version=${version:-$(get_apk_vers "https://www.apkmirror.com/uploads/?appcategory=$2" | get_largest_ver)}
	fi
	local base_apk="$1.apk"
	local dl_url=$(dl_apk "https://www.apkmirror.com/apk/$3-${version//./-}-release/" \
					"$url_regexp" \
					"$base_apk")
}

#################################################

# Patching apps with Revanced CLI:
patch() {
	if [ -f "$1.apk" ]; then
		java -jar revanced-cli*.jar \
		-m revanced-integrations*.apk \
		-b revanced-patches*.jar \
		-a $1.apk \
		${EXCLUDE_PATCHES[@]} \
		${INCLUDE_PATCHES[@]} \
		--keystore=./src/ks.keystore \
		-o ./build/$2.apk
		unset version
		unset EXCLUDE_PATCHES
		unset INCLUDE_PATCHES
	else 
		exit 1
	fi
}

#################################################

# Split architectures using Revanced CLI, created by j-hc:
archs=("arm64-v8a" "armeabi-v7a" "x86_64" "x86")
libs=("x86_64 x86 armeabi-v7a" "x86_64 x86 arm64-v8a" "x86 armeabi-v7a arm64-v8a" "x86_64 armeabi-v7a arm64-v8a")
gen_rip_libs() {
	for lib in $@; do
		echo -n "--rip-lib $lib "
	done
}
split_arch() {
	if [ -f "./build/$1.apk" ]; then
		java -jar revanced-cli*.jar \
		-b revanced-patches*.jar \
		-a ./build/$1.apk \
		--keystore=./src/ks.keystore \
		$3 \
		-o ./build/$2.apk
	else 
		exit 1
	fi
}

#################################################
