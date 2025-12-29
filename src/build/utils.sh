#!/bin/bash

# Constants
readonly APKMIRROR_BASE="https://www.apkmirror.com"
readonly APKPURE_BASE="https://apkpure.com"
readonly DOWNLOAD_DIR="./download"
readonly RELEASE_DIR="./release"

mkdir "$RELEASE_DIR" "$DOWNLOAD_DIR"

#Setup pup for download apk files
wget -q -O ./pup.zip https://github.com/ericchiang/pup/releases/download/v0.4.0/pup_v0.4.0_linux_amd64.zip
unzip "./pup.zip" -d "./" >/dev/null 2>&1
pup="./pup"
#Setup APKEditor for install combine split apks
wget -q -O ./APKEditor.jar https://github.com/REAndroid/APKEditor/releases/download/V1.4.7/APKEditor-1.4.7.jar
APKEditor="./APKEditor.jar"

#################################################

# Colored output logs
green_log() {
	echo -e "\e[32m$1\e[0m"
}
red_log() {
	echo -e "\e[31m$1\e[0m"
}

#################################################

# Download Github assets requirement:
dl_gh() {
	if [ "$3" == "prerelease" ]; then
		local repo=$1
		for repo in $1; do
			local owner=$2 tag=$3 found=0 assets=0
			releases=$(wget -qO- "https://api.github.com/repos/$owner/$repo/releases")
			while read -r line; do
				if [[ $line == *"\"tag_name\":"* ]]; then
					if [ "$tag" == "latest" ] || [ "$tag" == "prerelease" ]; then
						found=1
					else
						found=0
					fi
				fi
				if [[ $line == *"\"prerelease\":"* ]]; then
					prerelease=$(echo "$line" | cut -d ' ' -f 2 | tr -d ',')
					if [ "$tag" == "prerelease" ] && [ "$prerelease" == "true" ]; then
						found=1
					elif [ "$tag" == "prerelease" ] && [ "$prerelease" == "false" ]; then
						found=1
					fi
				fi
				if [[ $line == *"\"assets\":"* ]]; then
					if [ $found -eq 1 ]; then
						assets=1
					fi
				fi
				if [[ $line == *"\"browser_download_url\":"* ]]; then
					if [ $assets -eq 1 ]; then
						url=$(echo "$line" | cut -d '"' -f 4)
						if [[ $url != *.asc ]]; then
							name=$(basename "$url")
							wget -q -O "$name" "$url"
							green_log "[+] Downloading $name from $owner"
						fi
					fi
				fi
				if [[ $line == *"],"* ]]; then
					if [ $assets -eq 1 ]; then
						assets=0
						break
					fi
				fi
			done <<<"$releases"
		done
	else
		for repo in $1; do
			tags=$([ "$3" == "latest" ] && echo "latest" || echo "tags/$3")
			wget -qO- "https://api.github.com/repos/$2/$repo/releases/$tags" |
				jq -r '.assets[] | "\(.browser_download_url) \(.name)"' |
				while read -r url names; do
					if [[ $url != *.asc ]]; then
						green_log "[+] Downloading $names from $2"
						wget -q -O "$names" "$url"
					fi
				done
		done
	fi
}

#################################################

# Get patches list:
get_patches_key() {
	excludePatches=""
	includePatches=""
	excludeLinesFound=false
	includeLinesFound=false
	sed -i 's/\r$//' "src/patches/$1"/include-patches
	sed -i 's/\r$//' "src/patches/$1"/exclude-patches

	# Use CLI v5+ syntax: -d for disable, -e for enable
	while IFS= read -r line1; do
		excludePatches+=" -d \"$line1\""
		excludeLinesFound=true
	done <"src/patches/$1/exclude-patches"

	while IFS= read -r line2; do
		if [[ $line2 == *"|"* ]]; then
			patch_name="${line2%%|*}"
			options="${line2#*|}"
			includePatches+=" -e \"${patch_name}\" ${options}"
		else
			includePatches+=" -e \"$line2\""
		fi
		includeLinesFound=true
	done <"src/patches/$1/include-patches"

	if [ "$excludeLinesFound" = false ]; then
		excludePatches=""
	fi
	if [ "$includeLinesFound" = false ]; then
		includePatches=""
	fi
	export excludePatches
	export includePatches
}

#################################################

# Download apks files from APKMirror:
WGET_HEADERS=(
	--header="User-Agent: Mozilla/5.0 (Android 14; Mobile; rv:134.0) Gecko/134.0 Firefox/134.0"
	--header="Content-Type: application/octet-stream"
	--header="Accept-Language: en-US,en;q=0.9"
	--header="Connection: keep-alive"
	--header="Upgrade-Insecure-Requests: 1"
	--header="Cache-Control: max-age=0"
	--header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8"
	--keep-session-cookies
	--timeout=30
)

_req() {
	local output="${2/#-/$2}"
	[ "$2" != "-" ] && output="$DOWNLOAD_DIR/$2"
	wget -nv -O "$output" "${WGET_HEADERS[@]}" "$1" || rm -f "$output"
}
req() {
	_req "$1" "$2"
}

# Get file extension based on bundle type
get_apk_extension() {
	case "$1" in
	Bundle | Bundle_extract) echo "apkm" ;;
	*) echo "apk" ;;
	esac
}

# Process bundle file (merge or extract)
process_bundle() {
	local base_name="$1" bundle_type="$2" extension="$3"
	case "$bundle_type" in
	Bundle)
		green_log "[+] Merge splits apk to standalone apk"
		java -jar "$APKEditor" m -i "$DOWNLOAD_DIR/${base_name}.${extension}" -o "$DOWNLOAD_DIR/${base_name}.apk" >/dev/null 2>&1
		;;
	Bundle_extract)
		unzip "$DOWNLOAD_DIR/${base_name}.${extension}" -d "$DOWNLOAD_DIR/$(basename "${base_name}.${extension}" ".${extension}")" >/dev/null 2>&1
		;;
	esac
}

# Log download status
log_download_status() {
	local name="$1" file_path="$2"
	if [[ -f $file_path ]]; then
		green_log "[+] Successfully downloaded $name"
		return 0
	else
		red_log "[-] Failed to download $name"
		return 1
	fi
}

dl_apk() {
	local url=$1 regexp=$2 output=$3
	if [[ -z $4 ]] || [[ $4 == "Bundle" ]] || [[ $4 == "Bundle_extract" ]]; then
		url="${APKMIRROR_BASE}$(req "$url" - | tr '\n' ' ' | sed -n "s/.*<a[^>]*href=\"\([^\"]*\)\".*${regexp}.*/\1/p")"
	else
		url="${APKMIRROR_BASE}$(req "$url" - | tr '\n' ' ' | sed -n "s/href=\"/@/g; s;.*${regexp}.*;\1;p")"
	fi
	url="${APKMIRROR_BASE}$(req "$url" - | grep -oP 'class="[^"]*downloadButton[^"]*".*?href="\K[^"]+')"
	url="${APKMIRROR_BASE}$(req "$url" - | grep -oP 'id="download-link".*?href="\K[^"]+')"
	#url="${APKMIRROR_BASE}$(req "$url" - | $pup -p --charset utf-8 'a.downloadButton attr{href}')"
	#url="${APKMIRROR_BASE}$(req "$url" - | $pup -p --charset utf-8 'a#download-link attr{href}')"
	if [[ $url == "$APKMIRROR_BASE" ]]; then
		exit 0
	fi
	req "$url" "$output"
}

# Get compatible version from CLI patches list
get_version_from_cli() {
	local pkg="$1"
	java -jar ./*cli*.jar list-patches --with-packages --with-versions ./*.rvp |
		awk -v pkg="$pkg" '
			BEGIN { found = 0 }
			/^Index:/ { found = 0 }
			/Package name: / { if ($3 == pkg) { found = 1 } }
			/Compatible versions:/ {
				if (found) {
					getline
					latest_version = $1
					while (getline && $1 ~ /^[0-9]+\./) {
						latest_version = $1
					}
					print latest_version
					exit
				}
			}
		'
}

# Get URL regexp pattern based on architecture and bundle type
get_url_regexp() {
	local bundle_type="$1" arch="$2" dpi="$3" sdk="$4"

	if [[ -z $bundle_type ]]; then
		echo 'APK<\/span>'
	elif [[ $bundle_type == "Bundle" ]] || [[ $bundle_type == "Bundle_extract" ]]; then
		echo 'BUNDLE<\/span>'
	else
		case "$arch" in
		arm64-v8a | armeabi-v7a | x86 | x86_64)
			# shellcheck disable=SC2217
			echo "${arch}[^@]*${sdk}[^@]*${dpi}</div>[^@]*@\([^"]*\)"
			;;
		*)
			echo "${bundle_type}[^@]*${sdk}[^@]*${dpi} </div >[^@]*@\([^"]*\)"
			;;
		esac
	fi
}

# Core APK download logic
_download_apk_version() {
	local pkg="$1" base_name="$2" display_name="$3" url_base="$4"
	local bundle_type="$5" arch="$6" dpi="$7" sdk="$8" version="$9"

	local extension
	extension=$(get_apk_extension "$bundle_type")
	local base_apk="${base_name}.${extension}"
	local url_regexp
	url_regexp=$(get_url_regexp "$bundle_type" "$arch" "$dpi" "$sdk")

	version=$(echo "$version" | tr -d ' ' | sed 's/\./-/g')
	green_log "[+] Downloading $display_name version: $version $bundle_type $arch $dpi $sdk"

	dl_apk "${APKMIRROR_BASE}/apk/${url_base}-${version}-release/" \
		"$url_regexp" \
		"$base_apk" \
		"$bundle_type"

	if log_download_status "$base_name" "$DOWNLOAD_DIR/$base_apk"; then
		process_bundle "$base_name" "$bundle_type" "$extension"
		return 0
	else
		return 1
	fi
}

get_apk() {
	lock_version="${lock_version:-0}"
	local pkg="$1" base_name="$2" display_name="$3" url_base="$4"
	local bundle_type="$5" dpi="$6" sdk="$7"

	# Get version from CLI if not locked
	if [ -z "$version" ] && [ "$lock_version" != "1" ]; then
		version=$(get_version_from_cli "$pkg")
	fi

	export version="$version"

	# If version is set, try to download it directly
	if [[ -n $version ]]; then
		if _download_apk_version "$pkg" "$base_name" "$display_name" "$url_base" "$bundle_type" "$bundle_type" "$dpi" "$sdk" "$version"; then
			return 0
		else
			exit 1
		fi
	fi

	# Otherwise, try multiple versions from APKMirror uploads page
	local attempt=0
	while [ $attempt -lt 10 ]; do
		local upload_tail
		upload_tail="?$([[ $display_name == duolingo ]] && echo devcategory= || echo appcategory=)"
		version=$(req "${APKMIRROR_BASE}/uploads/$upload_tail$display_name" - |
			$pup 'div.widget_appmanager_recentpostswidget h5 a.fontBlack text{}' |
			grep -Evi 'alpha|beta' |
			grep -oPi '\b\d+(\.\d+)+(?:\-\w+)?(?:\.\d+)?(?:\.\w+)?\b' |
			sed -n "$((attempt + 1))p")

		if [[ -z $version ]]; then
			break
		fi

		if _download_apk_version "$pkg" "$base_name" "$display_name" "$url_base" "$bundle_type" "$bundle_type" "$dpi" "$sdk" "$version"; then
			return 0
		else
			((attempt++))
			red_log "[-] Failed to download $base_name, trying another version"
			unset version
		fi
	done

	red_log "[-] No more versions to try. Failed download"
	return 1
}
get_apkpure() {
	local pkg="$1" base_name="$2" display_name="$3" bundle_type="$4"

	# Get version from CLI if not locked
	if [ -z "$version" ] && [ "$lock_version" != "1" ]; then
		version=$(get_version_from_cli "$pkg")
	fi

	export version="$version"

	# Determine file extension
	local extension
	extension=$(get_apk_extension "$bundle_type")
	extension=${extension/apkm/xapk} # APKPure uses .xapk instead of .apkm
	local base_apk="${base_name}.${extension}"

	# Build download URL
	if [[ -n $version ]]; then
		url="${APKPURE_BASE}/$display_name/downloading/$version"
	else
		url="${APKPURE_BASE}/$display_name/downloading/"
		version="$(req "$url" - | awk -F'Download APK | \\(' '/<h2>/{print $2}')"
	fi

	green_log "[+] Downloading $base_name version: $version $bundle_type"
	url="$(req "$url" - | grep -oP '<a[^>]+id="download_link"[^>]+href="\Khttps://[^"]+')"
	req "$url" "$base_apk"

	if ! log_download_status "$base_name" "$DOWNLOAD_DIR/$base_apk"; then
		exit 1
	fi

	process_bundle "$base_name" "$bundle_type" "$extension"
}

#################################################

# Clear GitHub Actions environment variables (needed for inotia CLI)
unset_github_env() {
	unset CI GITHUB_ACTION GITHUB_ACTIONS GITHUB_ACTOR GITHUB_ENV GITHUB_EVENT_NAME \
		GITHUB_EVENT_PATH GITHUB_HEAD_REF GITHUB_JOB GITHUB_REF GITHUB_REPOSITORY \
		GITHUB_RUN_ID GITHUB_RUN_NUMBER GITHUB_SHA GITHUB_WORKFLOW GITHUB_WORKSPACE \
		RUN_ID RUN_NUMBER
}

# Patching apps with Revanced CLI:
patch() {
	green_log "[+] Patching $1:"
	if [ -f "$DOWNLOAD_DIR/$1.apk" ]; then
		local p b m ks a pu opt force
		if [ "$3" = inotia ]; then
			p="patch " b="-p *.rvp" m="" a="" ks=" --keystore=./src/_ks.keystore" pu="--purge=true" opt="--legacy-options=./src/options/$2.json" force=" --force"
			echo "Patching with Revanced-cli inotia"
		elif [ "$3" = morphe ]; then
			p="patch " b="-p *.mpp" m="" a="" ks="" pu="--purge=true" opt="" force=" --force"
			echo "Patching with Morphe"
		else
			# Use CLI v5+ syntax (current standard)
			p="patch " b="-p *.rvp" m="" a="" ks="ks" pu="--purge=true" opt="" force=" --force"
			echo "Patching with Revanced-cli version 5+"
		fi
		[ "$3" = inotia ] && unset_github_env
		eval java -jar ./*cli*.jar "$p""$b" "$m""$opt" --out="$RELEASE_DIR/$1-$2.apk""$excludePatches""$includePatches" --keystore=./src/"$ks".keystore "$pu""$force" "$a""$DOWNLOAD_DIR/$1.apk"
		unset version lock_version excludePatches includePatches
	else
		red_log "[-] Not found $1.apk"
		exit 1
	fi
}

#################################################

split_editor() {
	if [[ -z $3 || -z $4 ]]; then
		green_log "[+] Merge splits apk to standalone apk"
		java -jar $APKEditor m -i "$DOWNLOAD_DIR/$1" -o "$DOWNLOAD_DIR/$1.apk" >/dev/null 2>&1
		return 0
	fi
	IFS=' ' read -r -a include_files <<<"$4"
	mkdir -p "$DOWNLOAD_DIR/$2"
	for file in "$DOWNLOAD_DIR/$1"/*.apk; do
		filename=$(basename "$file")
		basename_no_ext="${filename%.apk}"
		if [[ $filename == "base.apk" ]]; then
			cp -f "$file" "$DOWNLOAD_DIR/$2/" >/dev/null 2>&1
			continue
		fi
		if [[ $3 == "include" ]]; then
			pattern=" $basename_no_ext "
			if [[ " ${include_files[*]} " =~ $pattern ]]; then
				cp -f "$file" "$DOWNLOAD_DIR/$2/" >/dev/null 2>&1
			fi
		elif [[ $3 == "exclude" ]]; then
			pattern=" $basename_no_ext "
			if [[ ! " ${include_files[*]} " =~ $pattern ]]; then
				cp -f "$file" "$DOWNLOAD_DIR/$2/" >/dev/null 2>&1
			fi
		fi
	done

	green_log "[+] Merge splits apk to standalone apk"
	java -jar "$APKEditor" m -i "$DOWNLOAD_DIR/$2" -o "$DOWNLOAD_DIR/$2.apk" >/dev/null 2>&1
}

#################################################

archs=("arm64-v8a" "armeabi-v7a" "x86_64" "x86")
gen_rip_libs() {
	for lib in "$@"; do
		echo -n "--rip-lib $lib "
	done
}
split_arch() {
	green_log "[+] Splitting $1 to ${archs[i]}:"
	if [ -f "$DOWNLOAD_DIR/$1.apk" ]; then
		unset_github_env
		eval java -jar ./revanced-cli*.jar patch \
			-p ./*.rvp \
			"$3" \
			--keystore=./src/_ks.keystore --force \
			--legacy-options=./src/options/"$2".json "$excludePatches""$includePatches" \
			--out="$RELEASE_DIR/$1-${archs[i]}-$2.apk" "$DOWNLOAD_DIR/$1.apk"
	else
		red_log "[-] Not found $1.apk"
		exit 1
	fi
}
#################################################

# Architecture Processing Helpers

# Generate architecture-specific exclusion patterns
# Usage: get_arch_excludes "arm64-v8a"
# Returns: Space-separated list of split configs to exclude
get_arch_excludes() {
	local target_arch="$1"
	case "$target_arch" in
	arm64-v8a)
		echo "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
		;;
	armeabi-v7a)
		echo "split_config.arm64_v8a split_config.x86 split_config.x86_64"
		;;
	x86)
		echo "split_config.arm64_v8a split_config.armeabi_v7a split_config.x86_64"
		;;
	x86_64)
		echo "split_config.arm64_v8a split_config.armeabi_v7a split_config.x86"
		;;
	all)
		echo "" # No exclusions for all-arch builds
		;;
	*)
		red_log "[-] Unknown architecture: $target_arch"
		return 1
		;;
	esac
}

# Generic architecture processing function
# Internal function used by process_architectures and process_lite_builds
_process_arch_builds() {
	local base_apk="$1" variant="$2" patch_key="$3" cli_mode="$4" archs_list="$5"
	local build_type="$6" # "standard" or "lite"

	for arch in $archs_list; do
		get_patches_key "$patch_key"

		if [[ $build_type == "lite" ]]; then
			green_log "[+] Processing lite build for $base_apk on $arch"
			local arch_normalized="${arch//-/_}"
			local includes="split_config.${arch_normalized} split_config.en split_config.xxxhdpi"
			split_editor "$base_apk" "${base_apk}-lite-${arch}" "include" "$includes"
			patch "${base_apk}-lite-${arch}" "$variant" "$cli_mode"
		elif [[ $arch == "all" ]]; then
			green_log "[+] Processing $base_apk for all architectures"
			patch "$base_apk" "$variant" "$cli_mode"
		else
			green_log "[+] Processing $base_apk for $arch"
			local excludes
			excludes=$(get_arch_excludes "$arch")
			split_editor "$base_apk" "${base_apk}-${arch}" "exclude" "$excludes"
			patch "${base_apk}-${arch}" "$variant" "$cli_mode"
		fi
	done
}

# Batch process multiple architectures for a base APK
# Usage: process_architectures "youtube" "revanced" "youtube-revanced" "" "arm64-v8a armeabi-v7a x86 x86_64"
# Args:
#   $1 - base_apk: Base APK name (without extension)
#   $2 - variant: Variant name (revanced, revanced-beta, etc.)
#   $3 - patch_key: Patch configuration key
#   $4 - cli_mode: Optional CLI mode (inotia, liso, or empty for standard)
#   $5 - archs: Space-separated architecture list (default: arm64-v8a armeabi-v7a x86 x86_64)
process_architectures() {
	_process_arch_builds "$1" "$2" "$3" "${4:-}" "${5:-arm64-v8a armeabi-v7a x86 x86_64}" "standard"
}

# Process lite builds (minimal splits with language/DPI)
# Usage: process_lite_builds "youtube" "revanced" "youtube-revanced" "" "arm64-v8a armeabi-v7a"
# Args:
#   $1 - base_apk: Base APK name (without extension)
#   $2 - variant: Variant name
#   $3 - patch_key: Patch configuration key
#   $4 - cli_mode: Optional CLI mode
#   $5 - archs: Space-separated architecture list for lite builds (default: arm64-v8a armeabi-v7a)
process_lite_builds() {
	_process_arch_builds "$1" "$2" "$3" "${4:-}" "${5:-arm64-v8a armeabi-v7a}" "lite"
}

#################################################
