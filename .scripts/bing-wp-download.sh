#!/usr/bin/env bash

PICTURE_DIR="$HOME/Pictures/bing-wallpapers/"

mkdir -p $PICTURE_DIR

urls=( $(curl -sL http://www.bing.com | \
    grep -Eo "url:'.*?'" | \
    sed -e "s/url:'\([^']*\)'.*/http:\/\/bing.com\1/" | \
    sed -e "s/\\\//g") )

for p in ${urls[@]}; do
    echo -n $(date +"%F %T")
    filename=$(echo $p|sed -e "s/.*\/\(.*\)/\1/")
    if [ ! -f "$PICTURE_DIR/$filename.png" ]; then
        echo " Downloading: $filename ..."
        curl -Lo "$PICTURE_DIR/$filename" $p
        convert "$PICTURE_DIR/$filename" "$PICTURE_DIR/$filename.png"
        rm "$PICTURE_DIR/$filename"
    else
        echo " Skipping: $filename ..."
    fi
done
