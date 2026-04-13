#
# Take a screenshot using grim and slup. Saves image to ~/Pictures/Screenshots
# with a timestamped filename, and copies it to the clipboard using wl-copy.
# If the function is run in an interactive shell, it will print a message to
# the terminal. If run in a non-interactive shell, it will send a desktop
# notification.
#
# TODO: add command args for whether to save, and timestamp format.
# TODO: maybe check for notify-send, though it should always be available
#
function grimslurp
    set -l message ""
    set -l image_path ""
    set -l date_fmt (set -q SCREENSHOT_DATE_FORMAT; and echo $SCREENSHOT_DATE_FORMAT; or echo "%FT%T")
    if command -q grim && command -q slurp && command -q wl-copy
        set image_path ~/Pictures/Screenshots/(date +$date_fmt).png
        grim -g (slurp) $image_path && wl-copy < $image_path
        set message "Imaged saved to $image_path and copied to clipboard."
    else
        set message "grim, slurp, and wl-copy are required for grimslurp to work."
    end

    if status is-interactive
        echo $message
    else
        notify-send "Screenshot saved" "$message" -i "$image_path" -a "Screenshot"
    end
end
