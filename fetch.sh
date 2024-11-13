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
ASSET_ID=(  $(cat repos.json | jq -r '.[].asset_id'))
NUM=(       $(cat repos.json | jq -r '.[].num'))
TYPE=(      $(cat repos.json | jq -r '.[].type'))
DIR=(      $(cat repos.json | jq -r '.[].dir'))

function Fetch() {
  params=($@)
  for param in ${!params[@]}; do

    user=${USR[$param]}
    repo=${REPO[$param]}
    file=${FILE[$param]}
    asset_id=${ASSET_ID[$param]}
    num=${NUM[$param]}
    type=${TYPE[$param]}
    dir=${DIR[$param]}
    
    if [[ ${user} == WE1ZARD ]]; then # release
        curl -sL -H "Authorization: token $TOKEN" -sL "$API/${user}/${repo}/releases/latest" | jq ".assets" | jq ".[${num}].url" | xargs -I {} curl -sL {} -H "Authorization: token $TOKEN" -H 'Accept:application/octet-stream' -o ${file}${type}
        # echo -e ${user}
        if [[ ${asset_id} > 0 ]]; then # pre-release 
            curl -sL -H "Accept: application/octet-stream" -H "Authorization: Bearer $TOKEN" "$API/${user}/${repo}/releases/assets/${asset_id}" -o ${file}"-pre"${type}
            #echo -e " ${file}-pre${type}"
        fi
    else
        curl -sL "$API/${user}/${repo}/releases" | jq ".[0].assets" | jq ".[${num}].browser_download_url" | xargs -I {} curl -sL {} -o ${file}${type}
        #echo -e ${user}
    fi

    if [[ "${dir}" != 0 ]]; then
      if [ ! -d "${dir}" ]; then
        mkdir -p "${dir}"
        #echo -e " make dir ${dir}"
      fi
      mv ${file}${type} ${dir}
      zip -rq "${file}.zip" ${dir}
      rm -rf ${dir}
      echo -e " ${file}${type}.zip"
    else
      echo -e "${GREEN} ${file}${type} ${RESET}"
    fi

  done
}

Fetch ${REPO[@]}