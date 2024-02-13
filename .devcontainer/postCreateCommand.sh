#!/usr/bin/env bash
echo '{ 
    "appsRepoUrl": "https://github.com/mir-one/TON-AppStore.git/"
}' > state/settings.json
npm i -g pnpm
pnpm i
sudo apt-get update
sudo apt-get install jq fswatch -y
mkdir logs
mkdir data
sudo chown node logs
sudo chown node data 
