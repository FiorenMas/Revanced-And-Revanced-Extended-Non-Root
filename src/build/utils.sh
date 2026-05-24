#!/bin/bash

mkdir ./release ./download

#Setup pup for download apk files
wget -q -O ./pup.zip https://github.com/ericchiang/pup/releases/download/v0.4.0/pup_v0.4.0_linux_amd64.zip
unzip "./pup.zip" -d "./" > /dev/null 2>&1
pup="./pup"
#Setup APKEditor for install combine split apks
wget -q -O ./APKEditor.jar https://github.com/REAndroid/APKEditor/releases/download/V1.4.8/APKEditor-1.4.8.jar
APKEditor="./APKEditor.jar"
#Find lastest user_agent
user_agent=$(wget -qO- https://www.whatismybrowser.com/guides/the-latest-user-agent/firefox | tr '\n' ' ' | sed 's#</tr>#\n#g' | grep 'Firefox (Standard)' | sed -n 's/.*<span class="code">\([^<]*Android[^<]*\)<\/span>.*/\1/p') \
|| user_agent=
[ -z "$user_agent" ] && {
  user_agent='Mozilla/5.0 (Android 16; Mobile; rv:146.0) Gecko/146.0 Firefox/146.0'
  echo "[-] Can't found lastest user-agent"
}

#################################################

# Colored output logs
green_log() {
    echo -e "\e[32m$1\e[0m"
}
red_log() {
    echo -e "\e[31m$1\e[0m"
}
yellow_log() {
    echo -e "\e[33m$1\e[0m"
}

#################################################

# Download Github assets requirement:
dl_gh() {
  if [ $3 == "prerelease" ]; then
    local repo=$1
    for repo in $1 ; do
      local owner=$2 tag=$3 found=0 assets=0
      releases=$(wget -qO- "https://api.github.com/repos/$owner/$repo/releases")
      while read -r line; do
        if [[ $line == *"\"tag_name\":"* ]]; then
          tag_name=$(echo $line | cut -d '"' -f 4)
          if [ "$tag" == "latest" ] || [ "$tag" == "prerelease" ]; then
            found=1
          else
            found=0
          fi
        fi
        if [[ $line == *"\"prerelease\":"* ]]; then
          prerelease=$(echo $line | cut -d ' ' -f 2 | tr -d ',')
          if [ "$tag" == "prerelease" ] && [ "$prerelease" == "true" ] ; then
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
            url=$(echo $line | cut -d '"' -f 4)
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
      done <<< "$releases"
    done
  else
    for repo in $1 ; do
      tags=$( [ "$3" == "latest" ] && echo "latest" || echo "tags/$3" )
      wget -qO- "https://api.github.com/repos/$2/$repo/releases/$tags" \
        | jq -r '.assets[] | "\(.browser_download_url) \(.name)"' \
        | while read -r url names; do
          if [[ $url != *.asc ]]; then
            if [[ "$3" == "latest" && "$names" == *dev* ]]; then
              continue
            fi
            green_log "[+] Downloading $names from $2"
            wget -q -O "$names" $url
          fi
        done
    done
  fi
}

dl_gl() {
  local repo=$1 owner=$2 tag=${3:-latest}
  local project_path="${owner}%2F${repo}"
  local api_url="https://gitlab.com/api/v4/projects/${project_path}/releases"

  local releases
  releases=$(wget -qO- "$api_url")

  local release
  if [[ "$tag" == "latest" ]]; then
    release=$(echo "$releases" | jq -r '[.[] | select(.tag_name | test("-dev") | not)][0]')
  elif [[ "$tag" == "prerelease" ]]; then
    release=$(echo "$releases" | jq -r '[.[] | select(.tag_name | test("-dev"))][0]')
  else
    release=$(wget -qO- "$api_url/$tag")
  fi

  if [[ -z "$release" ]] || [[ "$release" == "null" ]]; then
    red_log "[-] No matching release found for $owner/$repo ($tag)"
    return 1
  fi

  local tag_name
  tag_name=$(echo "$release" | jq -r '.tag_name')

  echo "$release" | jq -r '.assets.links[] | "\(.direct_asset_url // .url) \(.name)"' | \
    while read -r url name; do
      if [[ -n "$url" ]] && [[ "$url" != "null" ]] && [[ $url != *.asc ]]; then
        green_log "[+] Downloading $name from $owner"
        wget -q -O "$name" "$url"
      fi
    done
}

#################################################

# Get patches list:
get_patches_key() {
	excludePatches=""
	includePatches=""
	excludeLinesFound=false
	includeLinesFound=false

	local patchDir="src/patches/$1"
	local cliMode=""
	local patch_name options line1 line2 num

	sed -i 's/\r$//' "$patchDir/include-patches"
	sed -i 's/\r$//' "$patchDir/exclude-patches"

	if compgen -G "morphe-cli-*.jar" > /dev/null; then
		cliMode="morphe"
	elif compgen -G "revanced-cli-*.jar" > /dev/null; then
		if [[ $(ls revanced-cli-*.jar | head -n1) =~ revanced-cli-([0-9]+) ]]; then
			num=${BASH_REMATCH[1]}
			if [ "$num" -ge 5 ]; then
				cliMode="revanced_new"
			else
				cliMode="revanced_old"
			fi
		else
			cliMode="revanced_old"
		fi
	fi

	if [[ "$cliMode" == "morphe" ]]; then
		while IFS= read -r line1 || [[ -n "$line1" ]]; do
			[[ -z "$line1" ]] && continue
			excludePatches+=" -d \"$line1\""
			excludeLinesFound=true
		done < "$patchDir/exclude-patches"

		while IFS= read -r line2 || [[ -n "$line2" ]]; do
			[[ -z "$line2" ]] && continue
			patch_name="${line2%%|*}"
			includePatches+=" -e \"$patch_name\""
			includeLinesFound=true
		done < "$patchDir/include-patches"

	elif [[ "$cliMode" == "revanced_new" ]]; then
		while IFS= read -r line1 || [[ -n "$line1" ]]; do
			[[ -z "$line1" ]] && continue
			excludePatches+=" -d \"$line1\""
			excludeLinesFound=true
		done < "$patchDir/exclude-patches"

		while IFS= read -r line2 || [[ -n "$line2" ]]; do
			[[ -z "$line2" ]] && continue
			if [[ "$line2" == *"|"* ]]; then
				patch_name="${line2%%|*}"
				options="${line2#*|}"
				includePatches+=" -e \"${patch_name}\" ${options}"
			else
				includePatches+=" -e \"$line2\""
			fi
			includeLinesFound=true
		done < "$patchDir/include-patches"

	elif [[ "$cliMode" == "revanced_old" ]]; then
		while IFS= read -r line1 || [[ -n "$line1" ]]; do
			[[ -z "$line1" ]] && continue
			excludePatches+=" -e \"$line1\""
			excludeLinesFound=true
		done < "$patchDir/exclude-patches"

		while IFS= read -r line2 || [[ -n "$line2" ]]; do
			[[ -z "$line2" ]] && continue
			includePatches+=" -i \"$line2\""
			includeLinesFound=true
		done < "$patchDir/include-patches"
	fi

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

_req() {
    local cookie_args=()
    [[ -n "$FS_COOKIES" ]] && cookie_args=(--header "Cookie: $FS_COOKIES")
    if [ "$2" = "-" ]; then
        wget -nv -O "$2" --header="User-Agent: $user_agent" --header="Content-Type: application/octet-stream" --header="Accept-Language: en-US,en;q=0.9" --header="Connection: keep-alive" --header="Upgrade-Insecure-Requests: 1" --header="Cache-Control: max-age=0" --header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" "${cookie_args[@]}" --keep-session-cookies --timeout=30 "$1" || rm -f "$2"
    else
        wget -nv -O "./download/$2" --header="User-Agent: $user_agent" --header="Content-Type: application/octet-stream" --header="Accept-Language: en-US,en;q=0.9" --header="Connection: keep-alive" --header="Upgrade-Insecure-Requests: 1" --header="Cache-Control: max-age=0" --header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" "${cookie_args[@]}" --keep-session-cookies --timeout=30 "$1" || rm -f "./download/$2"
    fi
}
req() {
    _req "$1" "$2"
}

detect_version() {
	if [ -z "$version" ] && [ "$lock_version" != "1" ]; then
	  for spec in "revanced-cli-|5|*.rvp" "morphe-cli-|1|*.mpp"; do
		IFS="|" read -r jar_prefix min_major patch_glob <<<"$spec"

		if [[ $(ls "${jar_prefix}"*.jar 2>/dev/null) =~ ${jar_prefix}([0-9]+) ]]; then
		  num=${BASH_REMATCH[1]}

		  if [ "$num" -ge "$min_major" ]; then
			if [[ "$jar_prefix" == "morphe-cli-" ]]; then
			  list_patches_flags="list-patches --with-packages --with-versions --with-options --patches"
			elif [ "$num" -ge 6 ]; then
			  list_patches_flags="list-patches --packages --versions --options -bp"
			else
			  list_patches_flags="list-patches --with-packages --with-versions"
			fi
			version=$(java -jar *cli*.jar $list_patches_flags $patch_glob | awk -v pkg="$1" '
			  BEGIN { found = 0; printing = 0 }
			  /^Index:/ { if (printing) exit; found = 0 }
			  /Package name: / { if ($3 == pkg) found = 1 }
			  /Compatible versions:/ { if (found) printing = 1; next }
			  printing && $1 ~ /^[0-9]+\./ { print $1 }
			' | sort -V | tail -n1)
		  else
			version=$(jq -r '[.. | objects | select(.name == "'"$1"'" and .versions != null) | .versions[]] | reverse | .[0] // ""' *.json 2>/dev/null | uniq)
		  fi
		fi

		[ -n "$version" ] && break
	  done
	fi
}

_fs_get() {
	local url=$1
	local max_retries=5
	local attempt
	for attempt in $(seq 1 $max_retries); do
		local response
		response=$(curl -s -X POST 'http://localhost:8191/v1' \
			-H 'Content-Type: application/json' \
			-d "{\"cmd\":\"request.get\",\"url\":\"$url\",\"maxTimeout\":60000}")
		local status
		status=$(echo "$response" | jq -r '.status // empty')
		if [[ "$status" == "ok" ]]; then
			html=$(echo "$response" | jq -r '.solution.response // empty')
			export FS_COOKIES
			FS_COOKIES=$(echo "$response" | jq -r '[.solution.cookies[] | .name + "=" + .value] | join("; ")')
			user_agent=$(echo "$response" | jq -r '.solution.userAgent // empty')
			return 0
		fi
		yellow_log "[!] FlareSolverr attempt $attempt/$max_retries failed: $url"
		sleep 10
	done
	red_log "[-] FlareSolverr failed after $max_retries attempts: $url"
	return 1
}

get_apk() {
	local pkg_name=$1 apk_name=$2
	local pkg_type=${3:-apk} arch=${4:-} dpi=${5:-} minver=${6:-}
	local base_url="https://www.apkmirror.com"
	local html=""

	local apps_json="./src/build/apps.json"
	local list_url example_url
	list_url=$(jq -r --arg pkg "$pkg_name" '.apkmirror[$pkg].list_url // empty' "$apps_json")
	example_url=$(jq -r --arg pkg "$pkg_name" '.apkmirror[$pkg].example_url // empty' "$apps_json")

	if [[ -z "$list_url" ]]; then
		red_log "[-] Package $pkg_name not found in apps.json"
		return 1
	fi

	local base_apk
	if [[ "$pkg_type" == "bundle" ]] || [[ "$pkg_type" == "bundle_extract" ]]; then
		base_apk="$apk_name.apkm"
	else
		base_apk="$apk_name.apk"
	fi

	detect_version "$pkg_name"
	version=$(printf '%s\n' "$version" "$prefer_version" | sort -V | tail -n1)
	unset prefer_version
	export version

	green_log "[+] Detected version: ${version:-latest} [$pkg_name]"
	green_log "[+] Downloading $apk_name (type=$pkg_type arch=${arch:-any} dpi=$dpi)"

	local version_href=""

	if [[ -n "$example_url" && -n "$version" ]]; then
		version_href="${example_url#$base_url}"
		local slug_ver
		slug_ver=$(echo "$version_href" | grep -oP '\d+(-\d+)+' | tail -1)
		local target_ver
		target_ver=$(echo "$version" | tr '.' '-' | grep -oP '\d+(-\d+)+')
		if [[ -n "$slug_ver" ]]; then
			version_href="${version_href/$slug_ver/$target_ver}"
		fi
	else
		_fs_get "$list_url" || return 1

		version_href=$(echo "$html" | $pup 'h5.appRowTitle a.fontBlack json{}' | \
			jq -r '.[] | select(.text | test("(?i)beta|alpha") | not) | .href' | head -1)
		[[ -z "$version_href" ]] && \
			version_href=$(echo "$html" | $pup 'h5.appRowTitle a.fontBlack attr{href}' | head -1)

		if [[ -z "$version_href" ]]; then
			red_log "[-] Could not find release on APKMirror"
			return 1
		fi

		if [[ -n "$version" ]]; then
			local slug_ver
			slug_ver=$(echo "$version_href" | grep -oP '\d+(-\d+)+' | tail -1)
			local target_ver
			target_ver=$(echo "$version" | tr '.' '-' | grep -oP '\d+(-\d+)+')
			if [[ -n "$slug_ver" ]]; then
				version_href="${version_href/$slug_ver/$target_ver}"
			fi
		fi
	fi

	echo "$base_url$version_href"

	_fs_get "$base_url$version_href" || return 1

	if [[ "$html" == *"Page Not Found"* ]] || [[ "$html" == *"404 Whoops"* ]]; then
		yellow_log "[!] Version page not found, searching uploads pages..."
		local target_ver_dot="$version"
		version_href=""
		for page_num in $(seq 1 10); do
			local page_url="$list_url"
			if [[ $page_num -gt 1 ]]; then
				page_url="${list_url%%\?*}/page/$page_num/?${list_url#*\?}"
			fi
			_fs_get "$page_url" || return 1
			if [[ -n "$target_ver_dot" ]]; then
				version_href=$(echo "$html" | $pup 'h5.appRowTitle a.fontBlack json{}' | \
					jq -r --arg v "$target_ver_dot" '.[] | select(.text | contains($v)) | .href' | head -1)
			else
				version_href=$(echo "$html" | $pup 'h5.appRowTitle a.fontBlack json{}' | \
					jq -r '.[] | select(.text | test("(?i)beta|alpha") | not) | .href' | head -1)
			fi
			[[ -n "$version_href" ]] && break
		done
		if [[ -z "$version_href" ]]; then
			red_log "[-] Could not find version on APKMirror"
			return 1
		fi
		echo "$base_url$version_href"
		_fs_get "$base_url$version_href" || return 1
	fi

	local type_badge="APK"
	[[ "$pkg_type" == "bundle" || "$pkg_type" == "bundle_extract" ]] && type_badge="BUNDLE"

	local vtable_html rows variant_href=""
	vtable_html=$(echo "$html" | $pup 'div.variants-table')
	rows=$(echo "$vtable_html" | tr '\n' ' ' | sed 's/<div class="table-row/\n<div class="table-row/g')

	local dpi_fallback=("120-640dpi" "120-480dpi" "480-640dpi" "480dpi")
	local type_attempts=("$type_badge")
	if [[ "$type_badge" == "BUNDLE" ]]; then
		type_attempts+=("APK")
	else
		type_attempts+=("BUNDLE")
	fi

	local matched_type=""
	for try_type in "${type_attempts[@]}"; do
		local filtered_rows
		filtered_rows=$(echo "$rows" | grep -iP "apkm-badge[^>]*>\s*$try_type\s*<")
		[[ -n "$arch" ]] && filtered_rows=$(echo "$filtered_rows" | grep -i "$arch")
		[[ -n "$minver" ]] && filtered_rows=$(echo "$filtered_rows" | grep -i "$minver")

		if [[ -n "$dpi" ]]; then
			local dpi_filtered
			dpi_filtered=$(echo "$filtered_rows" | grep -i "$dpi")
			if [[ -z "$dpi_filtered" ]]; then
				for fb_dpi in "${dpi_fallback[@]}"; do
					dpi_filtered=$(echo "$filtered_rows" | grep -i "$fb_dpi")
					[[ -n "$dpi_filtered" ]] && { yellow_log "[!] DPI fallback: $dpi -> $fb_dpi"; break; }
				done
			fi
			filtered_rows="$dpi_filtered"
		fi

		variant_href=$(echo "$filtered_rows" | grep -oP 'accent_color[^>]*href="\K[^"]+' | head -1)
		if [[ -n "$variant_href" ]]; then
			matched_type="$try_type"
			[[ "$try_type" != "$type_badge" ]] && yellow_log "[!] Type fallback: $type_badge -> $try_type"
			break
		fi
	done

	if [[ -z "$variant_href" ]]; then
		red_log "[-] Could not find variant (type=$type_badge arch=${arch:-any} dpi=$dpi)"
		return 1
	fi
	variant_href=$(echo "$variant_href" | sed 's/&amp;/\&/g')
	echo "$base_url$variant_href"

	if [[ "$matched_type" == "BUNDLE" ]]; then
		base_apk="$apk_name.apkm"
	else
		base_apk="$apk_name.apk"
	fi

	_fs_get "$base_url$variant_href" || return 1

	local dl_btn_href
	local all_dl_btns
	all_dl_btns=$(echo "$html" | $pup 'a.downloadButton attr{href}')
	if [[ "$matched_type" == "BUNDLE" ]]; then
		dl_btn_href=$(echo "$all_dl_btns" | grep -v 'forcebaseapk' | head -1)
		[[ -z "$dl_btn_href" ]] && dl_btn_href=$(echo "$all_dl_btns" | head -1)
	else
		dl_btn_href=$(echo "$all_dl_btns" | grep 'forcebaseapk' | head -1)
		[[ -z "$dl_btn_href" ]] && dl_btn_href=$(echo "$all_dl_btns" | head -1)
	fi

	if [[ -z "$dl_btn_href" ]]; then
		red_log "[-] Could not find download button"
		return 1
	fi
	dl_btn_href=$(echo "$dl_btn_href" | sed 's/&amp;/\&/g')

	_fs_get "$base_url$dl_btn_href" || return 1

	local final_href
	final_href=$(echo "$html" | $pup 'a#download-link attr{href}' | head -1)
	[[ -z "$final_href" ]] && \
		final_href=$(echo "$html" | grep -oP 'id="download-link"[^>]*href="\K[^"]+' | head -1)

	if [[ -z "$final_href" ]]; then
		red_log "[-] Could not find final download link"
		return 1
	fi
	final_href=$(echo "$final_href" | sed 's/&amp;/\&/g')

	echo "$base_url$final_href"
	local cookie_args=()
	[[ -n "$FS_COOKIES" ]] && cookie_args=(--header "Cookie: $FS_COOKIES")
	wget -nv -O "./download/$base_apk" \
		--header="User-Agent: $user_agent" \
		--referer="$base_url$dl_btn_href" \
		"${cookie_args[@]}" \
		--timeout=120 \
		"$base_url$final_href"

	if [[ -f "./download/$base_apk" ]]; then
		green_log "[+] Successfully downloaded $apk_name"
	else
		red_log "[-] Failed to download $apk_name"
		return 1
	fi

	if [[ "$matched_type" == "BUNDLE" ]]; then
		if [[ "$pkg_type" == "bundle_extract" && "$type_badge" == "BUNDLE" ]]; then
			unzip "./download/$base_apk" -d "./download/$(basename "$base_apk" .apkm)" > /dev/null 2>&1
		else
			green_log "[+] Merge splits apk to standalone apk"
			java -jar $APKEditor m -i "./download/$apk_name.apkm" -o "./download/$apk_name.apk" > /dev/null 2>&1
		fi
	fi
}

get_apkpure() {
	local pkg_name=$1 apk_name=$2 pkg_type=${3:-apk}
	local html=""

	local apps_json="./src/build/apps.json"
	local base_download_url
	base_download_url=$(jq -r --arg pkg "$pkg_name" '.apkpure[$pkg].download_url // empty' "$apps_json")

	if [[ -z "$base_download_url" ]]; then
		red_log "[-] Package $pkg_name not found in apps.json (apkpure)"
		return 1
	fi

	detect_version "$pkg_name"
	version=$(printf '%s\n' "$version" "$prefer_version" | sort -V | tail -n1)
	unset prefer_version
	export version

	if [[ "$pkg_type" == "bundle" ]] || [[ "$pkg_type" == "bundle_extract" ]]; then
		local base_apk="$apk_name.xapk"
	else
		local base_apk="$apk_name.apk"
	fi

	local dl_page_url
	if [[ -n "$version" ]]; then
		dl_page_url="${base_download_url%/}/$version"
	else
		dl_page_url="$base_download_url"
	fi

	green_log "[+] Downloading $apk_name from APKPure (type=$pkg_type)"
	echo "$dl_page_url"

	_fs_get "$dl_page_url" || return 1

	if [[ -z "$version" ]]; then
		version=$(echo "$html" | $pup 'h2 text{}' | grep -oP '\d+(\.\d+)+' | head -1)
	fi
	green_log "[+] Version: $version"

	local download_url
	download_url=$(echo "$html" | $pup 'a#download_link attr{href}' | head -1)
	[[ -z "$download_url" ]] && \
		download_url=$(echo "$html" | grep -oP '<a[^>]+id="download_link"[^>]+href="\Khttps://[^"]+' | head -1)

	if [[ -z "$download_url" ]]; then
		red_log "[-] Could not find download link on APKPure"
		return 1
	fi
	echo "$download_url"

	local cookie_args=()
	[[ -n "$FS_COOKIES" ]] && cookie_args=(--header "Cookie: $FS_COOKIES")
	wget -nv -O "./download/$base_apk" \
		--header="User-Agent: $user_agent" \
		--referer="$dl_page_url" \
		"${cookie_args[@]}" \
		--timeout=120 \
		"$download_url"

	if [[ -f "./download/$base_apk" ]]; then
		green_log "[+] Successfully downloaded $apk_name"
	else
		red_log "[-] Failed to download $apk_name"
		return 1
	fi
	if [[ "$pkg_type" == "bundle" ]]; then
		if unzip -l "./download/$base_apk" 2>/dev/null | grep -q '\.apk$'; then
			green_log "[+] Merge splits apk to standalone apk"
			if ! java -jar $APKEditor m -i "./download/$apk_name.xapk" -o "./download/$apk_name.apk" > /dev/null 2>&1; then
				red_log "[-] Failed to merge $apk_name.xapk to standalone apk"
				return 1
			fi
		elif unzip -l "./download/$base_apk" 2>/dev/null | grep -q 'AndroidManifest.xml'; then
			green_log "[+] File is already a standalone APK, renaming"
			mv "./download/$base_apk" "./download/$apk_name.apk"
		else
			red_log "[-] Unknown file format for $base_apk"
			return 1
		fi
	elif [[ "$pkg_type" == "bundle_extract" ]]; then
		unzip "./download/$base_apk" -d "./download/$(basename "$base_apk" .xapk)" > /dev/null 2>&1
	fi
}

# Download files from Telegram channel/group
# Required secret in github setting TDL_BACKUP base64 backup file from https://docs.iyear.me/tdl/more/cli/tdl_backup/
# You must login your telegram (recommend use clone account) before backup https://docs.iyear.me/tdl/getting-started/quick-start/#login
telegram_dl() {
	local chat_id="$1" num_posts="$2" file_pattern="$3" out_name="$4"

	if [[ ! -f "./tdl" ]]; then
		green_log "[+] Downloading tdl from iyear"
		local tdl_url
		tdl_url=$(wget -qO- "https://api.github.com/repos/iyear/tdl/releases/latest" \
			| jq -r '.assets[] | select(.name | test("Linux_64bit\\.tar\\.gz$")) | .browser_download_url')
		wget -q -O ./tdl.tar.gz "$tdl_url"
		if [[ ! -f "./tdl.tar.gz" ]]; then
			red_log "[-] Failed to download tdl"
			return 1
		fi
		tar -xzf ./tdl.tar.gz tdl
		rm -f ./tdl.tar.gz
		chmod +x ./tdl
	fi

	echo "$TDL_BACKUP" | base64 -d > ./backup.tdl
	./tdl recover --file ./backup.tdl > /dev/null 2>&1
	rm -f ./backup.tdl

	local ext="${file_pattern##*.}"
	local filter="Media.Name endsWith '.$ext'"

	green_log "[+] Downloading from Telegram chat $chat_id last $num_posts posts matching '$file_pattern'"

	./tdl chat export -c "$chat_id" -T last -i "$num_posts" -f "$filter" -o ./tg_export.json > /dev/null 2>&1
	if [[ ! -f "./tg_export.json" ]]; then
		red_log "[-] Failed to export messages from Telegram"
		return 1
	fi

	jq '.messages = [.messages[0]]' ./tg_export.json > ./tg_export_one.json
	mv ./tg_export_one.json ./tg_export.json

	local tmp_dir="./tg_tmp_$$"
	mkdir -p "$tmp_dir"
	./tdl dl -f ./tg_export.json -d "$tmp_dir" > /dev/null 2>&1

	local dl_file
	dl_file=$(find "$tmp_dir" -type f | head -1)
	if [[ -n "$dl_file" ]]; then
		green_log "[+] Downloaded: $(basename "$dl_file")"
		mv "$dl_file" "./download/$out_name"
		rm -rf "$tmp_dir" ./tg_export.json
	else
		red_log "[-] Telegram download failed"
		rm -rf "$tmp_dir" ./tg_export.json
		return 1
	fi
}

#################################################

# Patching apps with Revanced CLI:
patch() {
	green_log "[+] Patching $1:"
	if [ -f "./download/$1.apk" ]; then
		local p b m ks a pu opt force
		if [ "$3" = inotia ]; then
			p="patch " b="-p *.rvp" m="" a="" ks=" --keystore=./src/_ks.keystore" pu="--purge=true" opt="--legacy-options=./src/options/$2.json" force=" --force"
			echo "Patching with Revanced-cli inotia"
		elif [ "$3" = morphe ]; then
			p="patch " b="-p *.mpp" m="" a="" ks=" --keystore=./src/morphe.keystore" pu="--purge=true" opt="--options-file ./src/options/$2.json" force=" --force --continue-on-error"
			echo "Patching with Morphe"
		else
			if [[ $(ls revanced-cli-*.jar) =~ revanced-cli-([0-9]+) ]]; then
				num=${BASH_REMATCH[1]}
				if [ $num -eq 6 ]; then
					p="patch " b="-bp *.rvp" m="" a="" ks=" --keystore=./src/ks.keystore" pu="--purge=true" opt="" force=" --force"
					echo "Patching with Revanced-cli version 6+"
				elif [ $num -eq 5 ]; then
					p="patch " b="-p *.rvp" m="" a="" ks=" --keystore=./src/ks.keystore" pu="--purge=true" opt="" force=" --force"
					echo "Patching with Revanced-cli version 5"
				elif [ $num -eq 4 ]; then
					p="patch " b="--patch-bundle *patch*.jar" m="--merge *integration*.apk " a="" ks=" --keystore=./src/ks.keystore" pu="--purge=true" opt="--options=./src/options/$2.json "
					echo "Patching with Revanced-cli version 4"
				elif [ $num -eq 3 ]; then
					p="patch " b="--patch-bundle *patch*.jar" m="--merge *integration*.apk " a="" ks=" --keystore=./src/_ks.keystore" pu="--purge=true" opt="--options=./src/options/$2.json "
					echo "Patching with Revanced-cli version 3"
				elif [ $num -eq 2 ]; then
					p="" b="--bundle *patch*.jar" m="--merge *integration*.apk " a="--apk " ks=" --keystore=./src/_ks.keystore" pu="--clean" opt="--options=./src/options/$2.json " force=" --experimental"
					echo "Patching with Revanced-cli version 2"
				fi
			fi
		fi
		if [[ "$3" = inotia || "$3" = morphe ]]; then
			unset CI GITHUB_ACTION GITHUB_ACTIONS GITHUB_ACTOR GITHUB_ENV GITHUB_EVENT_NAME GITHUB_EVENT_PATH GITHUB_HEAD_REF GITHUB_JOB GITHUB_REF GITHUB_REPOSITORY GITHUB_RUN_ID GITHUB_RUN_NUMBER GITHUB_SHA GITHUB_WORKFLOW GITHUB_WORKSPACE RUN_ID RUN_NUMBER
		fi
		eval java -jar *cli*.jar $p$b $m$opt --out=./release/$1-$2.apk$excludePatches$includePatches$ks $pu$force $a./download/$1.apk
  		unset version
		unset lock_version
		unset excludePatches
		unset includePatches
	else
		red_log "[-] Not found $1.apk"
		exit 1
	fi
}

lspatch() {
	green_log "[+] Patching $1:"
	if [ -f "./download/$1.apk" ]; then
		local module
		if [[ "$2" == *.apk ]]; then
			local -a matches=($2)
			module="${matches[0]}"
		else
			module="$2.apk"
		fi
		if [[ ! -f "$module" ]]; then
			red_log "[-] Module not found: $2"
			return 1
		fi
		java -jar lspatch.jar ./download/$1.apk -k ./src/fiorenmas.ks fiorenmas fiorenmas fiorenmas -m "$module" -o ./release/
		mv ./release/$1-*-lspatched.apk ./release/$1-$3-lspatched.apk
		unset version
		unset lock_version
	else
		red_log "[-] Not found $1.apk"
		exit 1
	fi
}
#################################################

split_editor() {
    if [[ -z "$3" || -z "$4" ]]; then
        green_log "[+] Merge splits apk to standalone apk"
        java -jar $APKEditor m -i "./download/$1" -o "./download/$1.apk" > /dev/null 2>&1
        return 0
    fi
    IFS=' ' read -r -a include_files <<< "$4"
    mkdir -p "./download/$2"
    for file in "./download/$1"/*.apk; do
        filename=$(basename "$file")
        basename_no_ext="${filename%.apk}"
        if [[ "$filename" == "base.apk" ]]; then
            cp -f "$file" "./download/$2/" > /dev/null 2>&1
            continue
        fi
        if [[ "$3" == "include" ]]; then
            if [[ " ${include_files[*]} " =~ " ${basename_no_ext} " ]]; then
                cp -f "$file" "./download/$2/" > /dev/null 2>&1
            fi
        elif [[ "$3" == "exclude" ]]; then
            if [[ ! " ${include_files[*]} " =~ " ${basename_no_ext} " ]]; then
                cp -f "$file" "./download/$2/" > /dev/null 2>&1
            fi
        fi
    done

    green_log "[+] Merge splits apk to standalone apk"
    java -jar $APKEditor m -i ./download/$2 -o ./download/$2.apk > /dev/null 2>&1
}

#################################################

archs=("arm64-v8a" "armeabi-v7a" "x86_64" "x86")
libs=("armeabi-v7a x86_64 x86" "arm64-v8a x86_64 x86" "armeabi-v7a arm64-v8a x86" "armeabi-v7a arm64-v8a x86_64")

# Remove unused architectures directly
apk_editor() {
	local apk="$1" keep="$2"; shift 2
	local dir="./download/$apk"
	rm -rf "$dir" && unzip -q "./download/$apk.apk" -d "$dir" || return 1
	for r in "$@"; do rm -rf "$dir/lib/$r"; done
	(cd "$dir" && zip -qr "../$apk-$keep.apk" .)
}

# Split architectures using Morphe cli
split_arch() {
	green_log "[+] Splitting $1 to ${archs[i]}:"
	if [ -f "./download/$1.apk" ]; then
		eval java -jar *cli*.jar patch \
		-p *.mpp $excludePatches$includePatches--options-file ./src/options/$2.json \
		--striplibs ${archs[i]} --purge=true \
		--keystore=./src/morphe.keystore --force \
		--out=./release/$1-${archs[i]}-$2.apk\
		./download/$1.apk
	else
		red_log "[-] Not found $1.apk"
		exit 1
	fi
}
