#
# Emoji picker using a dmenu-compatible menu tool.
# On first run, downloads emoji data from unicode.org and caches it locally.
# Presents a searchable list of emojis with their names, and copies the
# selected emoji to the clipboard using wl-copy.
#
# Usage: fishmoji [-c | --clip] [-t | --type] [-m | --menu <tool>] [-h | --help]
#   -c, --clip         Copy the selected emoji to the clipboard using wl-copy (default)
#   -t, --type         Type the selected emoji using wtype
#   -m, --menu <tool>  Use a specific menu tool (fuzzel, rofi, wofi)
#   -h, --help         Show this help message
#
# Requires: curl, wl-copy
# Supported menu tools: fuzzel, rofi, wofi (first found in this order is used)
# Optional: wtype (for --type)
#
function fishmoji
    argparse 'h/help' 'c/clip' 't/type' 'm/menu=' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: fishmoji [-c | --clip] [-t | --type] [-m | --menu <tool>] [-h | --help]"
        echo ""
        echo "An emoji picker using a dmenu-compatible menu tool. On first run, downloads"
        echo "emoji data from unicode.org and caches it locally. Recently used emojis"
        echo "appear at the top."
        echo ""
        echo "Options:"
        echo "  -c, --clip         Copy the selected emoji to the clipboard using wl-copy (default)"
        echo "  -t, --type         Type the selected emoji using wtype"
        echo "  -m, --menu <tool>  Use a specific menu tool (fuzzel, rofi, wofi)"
        echo "  -h, --help         Show this help message"
        echo ""
        echo "Requires: curl, wl-copy"
        echo "Supported menu tools: fuzzel, rofi, wofi (first found in this order is used)"
        echo "Optional: wtype (for --type)"
        return 0
    end

    # Default to clip if neither flag is given
    if not set -q _flag_clip; and not set -q _flag_type
        set _flag_clip true
    end

    # Determine menu tool
    set -l menu_tool
    if set -q _flag_menu
        set menu_tool $_flag_menu
    else
        for tool in fuzzel rofi wofi
            if command -q $tool
                set menu_tool $tool
                break
            end
        end
    end

    if test -z "$menu_tool"
        echo "fishmoji: no supported menu tool found (fuzzel, rofi, wofi)"
        return 1
    end

    # Build menu command for the selected tool
    set -l menu_cmd
    switch $menu_tool
        case fuzzel
            set menu_cmd fuzzel --dmenu --prompt "  "
        case rofi
            set menu_cmd rofi -dmenu -p "  " -i
        case wofi
            set menu_cmd wofi --show dmenu -p "  " -i
        case '*'
            echo "fishmoji: unsupported menu tool: $menu_tool"
            return 1
    end

    if not command -q curl
        echo "fishmoji: curl is required"
        return 1
    end

    if set -q _flag_clip; and not command -q wl-copy
        echo "fishmoji: wl-copy is required for --clip"
        return 1
    end

    if set -q _flag_type; and not command -q wtype
        echo "fishmoji: wtype is required for --type"
        return 1
    end

    set -l cache_dir (test -n "$XDG_DATA_HOME"; and echo "$XDG_DATA_HOME"; or echo "$HOME/.local/share")/fishmoji
    set -l cache_file $cache_dir/emojis.txt
    set -l history_dir (test -n "$XDG_STATE_HOME"; and echo "$XDG_STATE_HOME"; or echo "$HOME/.local/state")/fishmoji
    set -l history_file $history_dir/history.txt

    if not test -f $cache_file
        echo "fishmoji: downloading emoji data from unicode.org..."
        mkdir -p $cache_dir
        curl -sSL "https://unicode.org/Public/emoji/latest/emoji-test.txt" \
            | sed -ne 's/^.*; fully-qualified.*# \(\S*\) \S* \(.*$\)/\1 \2/gp' > $cache_file
        if test $pipestatus[1] -ne 0
            echo "fishmoji: failed to download emoji data"
            rm -f $cache_file
            return 1
        end
    end

    # Build list: recents sorted by frequency first, then full list with duplicates removed
    set -l selection
    if test -f $history_file
        set selection (
            begin
                sort $history_file | uniq -c | sort -rn | sed 's/^ *[0-9]* //'
                cat $cache_file
            end | cat -n | sort -uk2 | sort -n | cut -f2- \
            | $menu_cmd
        )
    else
        set selection ($menu_cmd < $cache_file)
    end

    if test -z "$selection"
        return 0
    end

    # Save selected line to history
    mkdir -p $history_dir
    echo $selection >> $history_file

    set -l emoji (string split ' ' $selection)[1]

    if set -q _flag_clip
        echo -n $emoji | wl-copy
        if status is-interactive
            echo "Copied $emoji to clipboard."
        end
    end

    if set -q _flag_type
        wtype -s 30 $emoji
    end
end
