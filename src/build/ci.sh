#!/bin/bash

# Check new patch:
get_date() {
	local assets asset name updated_at
	assets=$(curl -s https://api.github.com/repos/"$1"/releases/latest | jq '.assets')
	for asset in $(echo "$assets" | jq -r '.[] | @base64'); do
        	asset=$(echo "$asset" | base64 --decode)
		name=$(echo "$asset" | jq -r '.name')
		updated_at=$(echo "$asset" | jq -r '.updated_at')
		[[ $name =~ "$2" ]] && echo "$updated_at"
	done
}
checker(){
	local date1 date2 date1_sec date1_sec repo=$1 ur_repo=$repository check=$2
	date1=$(get_date "$repo" "patches.json")
	date2=$(get_date "$ur_repo" "$check")
	date1_sec=$(date -d "$date1" +%s)
	date2_sec=$(date -d "$date2" +%s)
	if [ -z "$date2" ] || [ "$date1_sec" -gt "$date2_sec" ]; then
		echo "new_patch=1" >> $GITHUB_OUTPUT
		echo -e "\e[32mNew patch, building...\e[0m"
	elif [ "$date1_sec" -lt "$date2_sec" ]; then
		echo "new_patch=0" >> $GITHUB_OUTPUT
		echo -e "\e[32mOld patch, not build.\e[0m"
	fi
}
checker $1 $2
