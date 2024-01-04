#!/bin/bash

# Setup Cloudflare warp for bypass cloudflare anti ddos APKMirror:
curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
sudo apt-get update && sudo apt-get install cloudflare-warp
sudo warp-svc >&/dev/null &
sleep 2
warp-cli --accept-tos register
warp-cli --accept-tos set-mode warp+doh
warp-cli --accept-tos connect
echo -e "\e[32mSuccessful install Cloudflare Warp\e[0m"
sleep 3