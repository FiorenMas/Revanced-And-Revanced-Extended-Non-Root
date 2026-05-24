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

# ... (UNCHANGED BELOW)
