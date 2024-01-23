#!/bin/bash

TIMESTAMP=$(date "+%Y%m%d%H%M%S")

LWA_FILE_PATHS=$(find . -print | grep "\.\(html\|js\|json\|css\|svg\|png\|jpg\|ttf\|woff\|woff2\)$" | grep -v "local_environment.js" | grep -v "octopus.json" | grep -v "package.json" | grep -v "bdns.json")

for file_path in $LWA_FILE_PATHS
do
  VERSION="v${1}"

  FILE_PREFIX=$(echo $file_path | grep -Po "^.*\/") 
  FILE_NAME=$(echo $file_path | grep -Po "\..+$" | grep -Po "[^\/]+\..+$")
  FILE_SUFFIX=$(echo $FILE_NAME | grep -Po "\..+$")
  FILE_NAME_NO_SUFFIX=$(echo $FILE_NAME | grep -Po "^[^\.]+")

  echo "${FILE_NAME}" | grep -q "index.html\|leaflet.html\|environment.js\|MainController.js\|LeafletController.js\|LeafletService.js"

  if [[ $(echo $?) -eq 0 ]]
  then
    VERSION="${TIMESTAMP}_${VERSION}"
  fi

  FILE_NAME_WITH_VERSION="${FILE_NAME_NO_SUFFIX}-${VERSION}${FILE_SUFFIX}"

  FILE_NAME_REF=$(grep -R --exclude-dir=".git" $FILE_NAME | grep -Po "^[^:]+")

  for file_ref in $FILE_NAME_REF
  do
    sed -i "s/$FILE_NAME/$FILE_NAME_WITH_VERSION/g" $file_ref
  done

  mv $file_path "${FILE_PREFIX}${FILE_NAME_WITH_VERSION}"
done

echo $TIMESTAMP
