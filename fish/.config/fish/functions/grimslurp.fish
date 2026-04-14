#
# Take a screenshot using grim and slurp. Saves image to ~/Pictures/Screenshots
# with a timestamped filename, and copies it to the clipboard using wl-copy.
# If run in an interactive shell, prints a message to the terminal.
# If run in a non-interactive shell, sends a desktop notification.
#
# TODO: add command args for whether to save, and timestamp format.
#
function grimslurp
    if not command -q grim; or not command -q slurp; or not command -q wl-copy
        set -l missing "grim, slurp, and wl-copy are required for grimslurp to work."
        if status is-interactive
            echo $missing
        else
            notify-send "grimslurp" "$missing" -a "Screenshot"
        end
        return 1
    end

    set -l date_fmt (set -q SCREENSHOT_DATE_FORMAT; and echo $SCREENSHOT_DATE_FORMAT; or echo "%FT%T")
    set -l image_path ~/Pictures/Screenshots/(date +$date_fmt).png

    grim -g (slurp) $image_path

    if test $status -eq 0
        wl-copy < $image_path
        if status is-interactive
            echo "Image saved to $image_path and copied to clipboard."
        else
            notify-send "Screenshot saved" "Saved to $image_path and copied to clipboard." -i "$image_path" -a "Screenshot"
        end
    else
        if status is-interactive
            return 0 # No need to echo, as the commands already echo when you cancel
        else
            notify-send "Screenshot canceled" -a "Screenshot"
        end
    end
end
