#!/bin/bash

# Check github connection stable or not:
check_connection() {
	if curl -s -I "https://api.github.com/repos/revanced/revanced-patches/releases/latest" > /dev/null; then
		echo "internet_error=0" >> $GITHUB_OUTPUT
		echo -e "\e[32mGithub connection OK\e[0m"
	else
		echo "internet_error=1" >> $GITHUB_OUTPUT
		echo -e "\e[31mGithub connection not stable!\e[0m"
	fi
}
check_connection
