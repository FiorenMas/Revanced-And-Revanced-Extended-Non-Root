#!/bin/bash

# Check github connection stable or not:
check_connection() {
	tag=$(curl -sIL -o /dev/null -w '%{url_effective}' "https://github.com/MorpheApp/morphe-patches/releases/latest" | grep -o '[^/]*$')

	mpp_path=$(curl -s "https://github.com/MorpheApp/morphe-patches/releases/expanded_assets/$tag" | grep -oE 'href="[^"]*\.mpp"' | head -n 1 | cut -d'"' -f2)
	mpp_url="https://github.com$mpp_path"
	mpp_name=$(basename "$mpp_path")

	wget -q "$mpp_url" || rm -f "$mpp_name"
	if [ -n "$mpp_name" ] && [ -f "$mpp_name" ]; then
		echo "internet_error=0" >> $GITHUB_OUTPUT
		echo -e "\e[32mGithub connection OK\e[0m"
		rm -f "$mpp_name"
	else
		echo "internet_error=1" >> $GITHUB_OUTPUT
		echo -e "\e[31mGithub connection not stable!\e[0m"
	fi
}
check_connection
