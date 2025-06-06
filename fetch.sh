#!/bin/bash
set -e

API="https://api.github.com/repos"
TOKEN=$1

GREEN='\033[0;32m'
RESET='\e[0m'

# ========================================================

# Pre-Release

# ========================================================
USR=(       $(cat repos.json | jq -r '.[].user'))
REPO=(      $(cat repos.json | jq -r '.[].repo'))
FILE=(      $(cat repos.json | jq -r '.[].filename'))
PRE=(       $(cat repos.json | jq -r '.[].pre'))
NUM=(       $(cat repos.json | jq -r '.[].num'))
TYPE=(      $(cat repos.json | jq -r '.[].type'))
DIR=(       $(cat repos.json | jq -r '.[].dir'))

function Fetch() {
  params=($@)
  for param in ${!params[@]}; do

    user=${USR[$param]}
    repo=${REPO[$param]}
    file=${FILE[$param]}
    pre=${PRE[$param]}
    num=${NUM[$param]}
    type=${TYPE[$param]}
    dir=${DIR[$param]}
    
    if [[ ${user} == WE1ZARD ]]; then # release
        curl -sL -H "Authorization: token $TOKEN" -sL "$API/${user}/${repo}/releases/latest" | jq ".assets[${num}].url" | xargs -I {} curl -sL {} -H "Authorization: token $TOKEN" -H 'Accept:application/octet-stream' -o ${file}${type}
        echo -e " ${file}${type}"
        if [[ ${pre} > 0 ]]; then # pre-release 
            curl -sL -H "Authorization: token $TOKEN" -sL "$API/${user}/${repo}/releases" | jq -r '.[] | select(.prerelease).assets[].url' | xargs -I {} curl -sL -H "Accept: application/octet-stream" -H "Authorization: Bearer $TOKEN" {} -o ${file}"-pre"${type}; 
            echo -e " ${file}-pre${type}"
        fi
    else
        curl -sL "$API/${user}/${repo}/releases" | jq ".[0].assets" | jq ".[${num}].browser_download_url" | xargs -I {} curl -sL {} -o ${file}${type}
        echo -e ${user} ${file}${type}
    fi

    if [[ "${dir}" != 0 ]]; then
      if [ ! -d "${dir}" ]; then
        mkdir -p "${dir}"
        echo -e " make dir ${dir}"
      fi
      mv ${file}${type} ${dir}
      zip -rq9 "${file}.zip" ${dir}
      rm -rf ${dir}
      echo -e " ${file}.zip"
    else
      echo -e "${GREEN} ${file}${type} ${RESET}"
    fi

  done
}

Fetch ${REPO[@]}

# 60FPSLocker
curl -sL https://github.com/masagrator/FPSLocker-Warehouse/archive/refs/heads/v3.zip -o v3.zip
unzip -oq mhr.zip
unzip -oq v3.zip
cp -r ./FPSLocker-Warehouse-3/SaltySD ./
zip -rq9 60FPSLocker.zip ./SaltySD

# nyx.bin
#zip -rq9 nyx.zip ./nyx.bin

# chiaki-ng
# curl -sL "https://api.github.com/repos/streetpea/chiaki-ng/releases" | jq -r 'first(.[] | select(.prerelease).assets[] | select(.name=="chiaki-ng.nro").browser_download_url)' | xargs -I {} curl -sL {} -o chiaki-ng.nro
# mkdir -p ./switch/chiaki
# mv ./chiaki-ng.nro ./switch/chiaki
# zip -rq9 chiaki-ng.zip ./switch
# rm -rf ./switch

## theme patches
curl -sL https://github.com/exelix11/theme-patches/archive/refs/heads/master.zip -o master.zip
curl -sL "https://api.github.com/repos/exelix11/SwitchThemeInjector/releases" | jq ".[0].assets" | jq ".[0].browser_download_url" | xargs -I {} curl -sL {} -o NXThemesInstaller.nro
unzip -oq master.zip
mkdir -p ./switch
mkdir -p ./themes
mv ./NXThemesInstaller.nro ./switch
cp -r ./theme-patches-master/systemPatches ./themes
zip -rq9 theme.zip ./switch ./themes
rm -rf ./themes ./theme-patches-master ./switch ./master.zip