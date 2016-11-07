#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/bing-wallpapers"
WALLPAPER=$(ls $WALLPAPER_DIR | shuf | tail -1)
DISPLAY=:0 feh --bg-fill "$WALLPAPER_DIR/$WALLPAPER"
