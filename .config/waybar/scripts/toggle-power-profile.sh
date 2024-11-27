#!/bin/sh

current_profile=$(powerprofilesctl get)

if [ $current_profile = "power-saver" ]; then
	exec powerprofilesctl set balanced
elif [ $current_profile = "balanced" ]; then
	exec powerprofilesctl set performance
else
	exec powerprofilesctl set power-saver
fi
