#!/bin/bash
# vol_control.sh - Adjust volume of a specific app by a percentage
#
# Usage:
#   ./vol_control.sh <app_name> <percent_change>
#   ./vol_control.sh spotify +10
#   ./vol_control.sh firefox -5
#   ./vol_control.sh discord 50    (set absolute)
#
# Requires: pipewire/pulseaudio (pactl)

set -euo pipefail

usage() {
    echo "Usage: $0 <app_name> <percent_change>"
    echo "  app_name:       partial name of the app (case-insensitive)"
    echo "  percent_change: relative change, e.g. +10, -5 (or absolute if no +/-)"
    echo ""
    echo "List active sink inputs:"
    echo "  pactl list sink-inputs"
    exit 1
}

[[ $# -lt 2 ]] && usage

APP="$1"
CHANGE="$2"

# Find sink-input IDs matching the app name, tracking corked state.
# PipeWire uses "Corked: yes/no" (not "State: RUNNING/CORKED").
# Output format: "id corked" per line (corked = yes|no)
MATCHES=$(pactl list sink-inputs | awk -v app="${APP,,}" '
    /^Sink Input #/ { id = substr($3, 2); corked = ""; printed = 0 }
    /^\s+Corked:/ { corked = $2 }
    /application\.name|application\.process\.binary|application\.icon_name/ {
        if (!printed) {
            val = tolower($0)
            if (index(val, app)) { print id, corked; printed = 1 }
        }
    }
')

if [[ -z "$MATCHES" ]]; then
    echo "Error: no audio stream found matching \"$APP\""
    echo "Active streams:"
    pactl list sink-inputs | awk '
        /^Sink Input #/ { id = substr($3, 2); corked = "" }
        /^\s+Corked:/ { corked = $2 }
        /application\.name =/ {
            gsub(/.*= "|"/, "")
            printf "  #%s  corked=%-3s  %s\n", id, corked, $0
        }
    '
    exit 1
fi

# Prefer uncorked (actively playing) streams; fall back to all matches
ACTIVE_IDS=$(echo "$MATCHES" | awk '$2 == "no" { print $1 }')
if [[ -n "$ACTIVE_IDS" ]]; then
    SINK_IDS="$ACTIVE_IDS"
else
    SINK_IDS=$(echo "$MATCHES" | awk '{ print $1 }')
fi

PACTL_OUTPUT=$(pactl list sink-inputs)

for SINK_ID in $SINK_IDS; do
    # Get current volume percentage for this sink input
    CURRENT_VOL=$(echo "$PACTL_OUTPUT" | awk -v id="$SINK_ID" '
        /^Sink Input #/ { cur = substr($3, 2) }
        cur == id && /^\s+Volume:/ {
            match($0, /([0-9]+)%/, m)
            print m[1]
            exit
        }
    ')

    # Determine new volume
    if [[ "$CHANGE" =~ ^[+-] ]]; then
        NEW_VOL=$(( CURRENT_VOL + CHANGE ))
    else
        NEW_VOL="$CHANGE"
    fi

    # Clamp to 0–100
    if (( NEW_VOL < 0 )); then NEW_VOL=0; fi
    if (( NEW_VOL > 100 )); then NEW_VOL=100; fi

    pactl set-sink-input-volume "$SINK_ID" "${NEW_VOL}%"
    echo "[$APP #$SINK_ID] volume: ${CURRENT_VOL}% → ${NEW_VOL}%"
done
