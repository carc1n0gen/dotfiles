#
# A cowsay-inspired ASCII art speech bubble generator, powered by fish.
# Creature art is defined in ~/.local/share/fishsay/fish/<name>.fish files,
# each setting a $the_fish variable with {thoughts} as the connector
# placeholder.
#
# Usage: fishsay [-f <name>] [-W <width>] [-n] [-r] [-l] [-h] [message]
#   If no message is given, reads from stdin.
#
# Options:
#   -f, --file <name>  Use a named creature (default: fish)
#   -r, --random           Pick a random creature
#   -W, --wrap <width>     Wrap message at <width> characters (default: 40)
#   -n, --nowrap           Disable word wrapping
#   -l, --list             List available creatures
#   -h, --help             Show this help message
#
function fishsay
    argparse 'h/help' 'f/file=' 'r/random' 'W/wrap=' 'n/nowrap' 'l/list' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: fishsay [-f <name>] [-W <width>] [-n] [-r] [-l] [-h] [message]"
        echo ""
        echo "A cowsay-inspired ASCII art speech bubble generator."
        echo ""
        echo "Options:"
        echo "  -f, --file <name>  Use a named creature (default: fish)"
        echo "  -r, --random           Pick a random creature"
        echo "  -W, --wrap <width>     Wrap message at <width> characters (default: 40)"
        echo "  -n, --nowrap           Disable word wrapping"
        echo "  -l, --list             List available creatures"
        echo "  -h, --help             Show this help message"
        return 0
    end

    set -l data_dir
    if test -n "$XDG_DATA_HOME"
        set data_dir $XDG_DATA_HOME
    else
        set data_dir $HOME/.local/share
    end
    set -l creatures_dir $data_dir/fishsay/fish

    if set -q _flag_list
        for f in $creatures_dir/*.fish
            basename $f .fish
        end
        return 0
    end

    # Gather the message
    set -l message
    if test (count $argv) -gt 0
        set message (string join ' ' $argv)
    else if not isatty stdin
        set -l stdin_lines
        while read -l line
            set -a stdin_lines $line
        end
        set message (string join ' ' $stdin_lines)
    else
        echo "fishsay: no message provided. Try: fishsay 'hello!'" >&2
        return 1
    end

    # Wrap width
    set -l wrap 40
    if set -q _flag_wrap
        set wrap $_flag_wrap
    end

    # Load creature
    set -l creature_name fish
    if set -q _flag_random
        set -l all_creatures $creatures_dir/*.fish
        set creature_name (basename (echo $all_creatures[(random 1 (count $all_creatures))]) .fish)
    else if set -q _flag_file
        set creature_name $_flag_file
    end

    set -l creature_file $creatures_dir/$creature_name.fish
    if not test -f $creature_file
        echo "fishsay: creature '$creature_name' not found in $creatures_dir" >&2
        return 1
    end

    source $creature_file

    if not set -q the_fish
        echo "fishsay: '$creature_name.fish' did not define \$the_fish" >&2
        return 1
    end

    # Word-wrap the message into lines
    set -l lines
    if set -q _flag_nowrap
        set lines (string split \n $message)
    else
        set lines (echo $message | expand | fold -s -w $wrap)
    end

    # Find the longest line for border width
    set -l max_len 0
    for line in $lines
        set -l len (string length -- $line)
        if test $len -gt $max_len
            set max_len $len
        end
    end

    # Draw the speech bubble
    set -l border (string repeat -n (math $max_len + 2) '-')
    echo " $border"

    set -l num_lines (count $lines)
    for i in (seq $num_lines)
        set -l line $lines[$i]
        set -l padding (string repeat -n (math $max_len - (string length -- $line)) ' ')
        if test $num_lines -eq 1
            echo "< $line$padding >"
        else if test $i -eq 1
            echo "/ $line$padding \\"
        else if test $i -eq $num_lines
            echo "\\ $line$padding /"
        else
            echo "| $line$padding |"
        end
    end

    echo " $border"

    # Render the creature, substituting {thoughts} with the connector
    echo $the_fish | string replace -a '{thoughts}' "\\"
end
