#!/bin/bash

# Check github connection stable or not:
check_connection() {
	wget -q $(curl -s "https://api.github.com/repos/MorpheApp/morphe-patches/releases/tags/v1.21.1" | jq -r '.assets[] | select(.name == "patches-1.21.1.mpp") | .browser_download_url') || rm -f "patches-1.21.1.mpp"
	if [ -f patches-1.21.1.mpp ]; then
		echo "internet_error=0" >> $GITHUB_OUTPUT
		echo -e "\e[32mGithub connection OK\e[0m"
		rm -f "patches-1.21.1.mpp"
	else
		echo "internet_error=1" >> $GITHUB_OUTPUT
		echo -e "\e[31mGithub connection not stable!\e[0m"
	fi
}
check_connection
