#
# fishfetch - A fastfetch-inspired system info display written in pure fish.
# Supports macOS and Linux. Displays a fish ASCII art logo alongside
# system information with colored labels.
#
function fishfetch
    # ── Gather System Info ──────────────────────────────────────────────

    # Parse uname once: "Linux hostname 6.x.x x86_64" or "Darwin hostname 24.x.x arm64"
    set -l uname_parts (string split ' ' (uname -snrm))
    set -l os_type $uname_parts[1]
    set -l uname_nodename $uname_parts[2]
    set -l uname_release $uname_parts[3]
    set -l uname_machine $uname_parts[4]
    set -l info_lines

    # Fire slow queries in parallel
    set -l _ff_tmpdir ""
    set -l _ff_hw_pid ""
    set -l _ff_dp_pid ""
    set -l _ff_lspci_pid ""
    set -l _ff_df_pid ""
    if test "$os_type" = Darwin; and command -q system_profiler
        set _ff_tmpdir (mktemp -d)
        system_profiler SPHardwareDataType >$_ff_tmpdir/hw 2>/dev/null &
        set _ff_hw_pid $last_pid
        system_profiler SPDisplaysDataType >$_ff_tmpdir/dp 2>/dev/null &
        set _ff_dp_pid $last_pid
    else if test "$os_type" = Linux
        set _ff_tmpdir (mktemp -d)
        if command -q lspci
            lspci >$_ff_tmpdir/lspci 2>/dev/null &
            set _ff_lspci_pid $last_pid
        end
        df -h / >$_ff_tmpdir/df 2>/dev/null &
        set _ff_df_pid $last_pid
    end

    # Title: user@hostname
    set -l user $USER
    set -l host
    if command -q hostname
        set host (hostname -s 2>/dev/null; or hostname)
    else
        set host (string replace -r '\..*' '' $uname_nodename)
    end
    set -a info_lines title (set_color cyan)"$user"(set_color white)"@"(set_color cyan)"$host"(set_color normal)
    set -a info_lines separator (set_color brblack)(string repeat -n (math (string length "$user") + 1 + (string length "$host")) '─')(set_color normal)

    # OS
    if test "$os_type" = Darwin
        set -l os_name (sw_vers -productName 2>/dev/null; or echo macOS)
        set -l os_version (sw_vers -productVersion 2>/dev/null; or echo "")
        set -l os_build (sw_vers -buildVersion 2>/dev/null; or echo "")
        set -a info_lines os "$os_name $os_version $os_build ($uname_machine)"
    else
        set -l os_pretty ""
        if test -f /etc/os-release
            while read -l line
                if string match -q 'PRETTY_NAME=*' $line
                    set os_pretty (string replace 'PRETTY_NAME=' '' $line | string trim -c '"')
                    break
                end
            end </etc/os-release
        end
        if test -z "$os_pretty"
            set os_pretty (uname -o 2>/dev/null; or echo Linux)
        end
        set -a info_lines os "$os_pretty ($uname_machine)"
    end

    # Host / Model
    if test "$os_type" = Darwin
        set -l model (sysctl -n hw.model 2>/dev/null)
        set -l brand ""
        if test -n "$_ff_hw_pid"
            wait $_ff_hw_pid
            set brand (grep "Model Name" $_ff_tmpdir/hw | string replace -r '.*: ' '')
        end
        if test -n "$brand"
            set -a info_lines host "$brand ($model)"
        else if test -n "$model"
            set -a info_lines host "Apple $model"
        end
    else
        set -l product ""
        if test -f /sys/devices/virtual/dmi/id/product_name
            read product </sys/devices/virtual/dmi/id/product_name 2>/dev/null
            set product (string trim $product)
        end
        set -l vendor ""
        if test -f /sys/devices/virtual/dmi/id/sys_vendor
            read vendor </sys/devices/virtual/dmi/id/sys_vendor 2>/dev/null
            set vendor (string trim $vendor)
        end
        if test -n "$product" -a "$product" != "System Product Name"
            if test -n "$vendor"
                set -a info_lines host "$vendor $product"
            else
                set -a info_lines host "$product"
            end
        end
    end

    # Kernel
    set -a info_lines kernel $uname_release

    # Uptime
    if test "$os_type" = Darwin
        set -l boot_epoch (sysctl -n kern.boottime 2>/dev/null | string replace -r '.*\{ sec = (\d+),.*' '$1')
        if test -n "$boot_epoch"
            set -l now_epoch (date +%s)
            set -l up_secs (math $now_epoch - $boot_epoch)
            set -a info_lines uptime (_fishfetch_format_uptime $up_secs)
        end
    else
        if test -f /proc/uptime
            set -l uptime_raw
            read uptime_raw </proc/uptime
            set -l up_secs (string split ' ' $uptime_raw)[1]
            set up_secs (math "floor($up_secs)")
            set -a info_lines uptime (_fishfetch_format_uptime $up_secs)
        end
    end

    # Shell
    set -a info_lines shell "fish $FISH_VERSION"

    # Terminal
    set -l term ""
    if test -n "$TERM_PROGRAM"
        set term "$TERM_PROGRAM"
        if test -n "$TERM_PROGRAM_VERSION"
            set term "$term $TERM_PROGRAM_VERSION"
        end
    else if test -n "$TERM"
        set term "$TERM"
    end
    if test -n "$term"
        set -a info_lines terminal "$term"
    end

    # Desktop / WM
    if test "$os_type" != Darwin
        set -l de ""
        if test -n "$XDG_CURRENT_DESKTOP"
            set de "$XDG_CURRENT_DESKTOP"
        else if test -n "$DESKTOP_SESSION"
            set de "$DESKTOP_SESSION"
        end
        if test -n "$de"
            set -a info_lines de "$de"
        end

        set -l wm ""
        if test -n "$HYPRLAND_INSTANCE_SIGNATURE"
            set wm Hyprland
        else if test -n "$SWAYSOCK"
            set wm Sway
        else if test -n "$I3SOCK"
            set wm i3
        end
        if test -n "$wm"
            set -a info_lines wm "$wm"
        end
    else
        set -a info_lines de "Aqua"
    end

    # CPU
    if test "$os_type" = Darwin
        set -l cpu (sysctl -n machdep.cpu.brand_string 2>/dev/null)
        if test -n "$cpu"
            set -a info_lines cpu (string trim "$cpu")
        end
    else
        set -l cpu ""
        if test -f /proc/cpuinfo
            while read -l line
                if string match -q 'model name*' $line
                    set cpu (string replace -r '.*: ' '' $line)
                    break
                end
            end </proc/cpuinfo
        end
        if test -n "$cpu"
            set -a info_lines cpu (string trim "$cpu")
        end
    end

    # GPU
    if test "$os_type" = Darwin
        set -l gpu ""
        if test -n "$_ff_dp_pid"
            wait $_ff_dp_pid
            set gpu (grep "Chipset Model\|Chip Model" $_ff_tmpdir/dp | head -1 | string replace -r '.*: ' '')
        end
        if test -n "$gpu"
            set -a info_lines gpu (string trim "$gpu")
        end
    else
        if test -n "$_ff_lspci_pid"
            wait $_ff_lspci_pid
            set -l gpu (grep -i 'vga\|3d\|display' $_ff_tmpdir/lspci 2>/dev/null | head -1 | string replace -r '.*: ' '')
            if test -n "$gpu"
                # Strip "(rev XX)" suffix
                set gpu (string replace -r '\s*\(rev \w+\)\s*$' '' $gpu | string trim)
                # Extract last [bracketed product name] if present
                set -l product (string match -r '.*\[([^\]]+)\][^\[]*$' $gpu)[2]
                if test -n "$product"
                    if string match -qi '*NVIDIA*' $gpu
                        set gpu "NVIDIA $product"
                    else if string match -qi '*AMD*' $gpu; or string match -qi '*ATI*' $gpu
                        set gpu "AMD $product"
                    else if string match -qi '*Intel*' $gpu
                        set gpu "Intel $product"
                    else
                        set gpu $product
                    end
                end
                set -a info_lines gpu (string trim "$gpu")
            end
        end
    end

    # Memory
    if test "$os_type" = Darwin
        set -l mem_total_bytes (sysctl -n hw.memsize 2>/dev/null)
        set -l mem_total_mib (math "floor($mem_total_bytes / 1048576)")
        # vm_stat page size and used pages
        set -l page_size (sysctl -n hw.pagesize 2>/dev/null; or echo 16384)
        set -l vm (vm_stat 2>/dev/null)
        set -l active (string join \n $vm | grep "Pages active" | string replace -r '.*: *(\d+).*' '$1')
        set -l wired (string join \n $vm | grep "Pages wired" | string replace -r '.*: *(\d+).*' '$1')
        set -l compressed (string join \n $vm | grep "Pages occupied by compressor" | string replace -r '.*: *(\d+).*' '$1')
        if test -n "$active" -a -n "$wired"
            test -z "$compressed"; and set compressed 0
            set -l used_pages (math "$active + $wired + $compressed")
            set -l mem_used_mib (math "floor($used_pages * $page_size / 1048576)")
            set -a info_lines memory "$mem_used_mib MiB / $mem_total_mib MiB"
        else
            set -a info_lines memory "? / $mem_total_mib MiB"
        end
    else
        if test -f /proc/meminfo
            set -l mem_total ""
            set -l mem_avail ""
            while read -l line
                if string match -q 'MemTotal:*' $line
                    set mem_total (string replace -r '.*: *(\d+).*' '$1' $line)
                else if string match -q 'MemAvailable:*' $line
                    set mem_avail (string replace -r '.*: *(\d+).*' '$1' $line)
                end
                test -n "$mem_total" -a -n "$mem_avail"; and break
            end </proc/meminfo
            if test -n "$mem_total" -a -n "$mem_avail"
                set -l mem_total_mib (math "floor($mem_total / 1024)")
                set -l mem_used_mib (math "floor(($mem_total - $mem_avail) / 1024)")
                set -a info_lines memory "$mem_used_mib MiB / $mem_total_mib MiB"
            end
        end
    end

    # Disk (wait for backgrounded df on Linux, run inline on macOS)
    set -l disk_info ""
    if test -n "$_ff_df_pid"
        wait $_ff_df_pid
        set disk_info (tail -1 $_ff_tmpdir/df 2>/dev/null)
    else
        set disk_info (df -h / 2>/dev/null | tail -1)
    end
    if test -n "$disk_info"
        set -l disk_parts (string split -n ' ' (string trim "$disk_info"))
        # df -h columns: filesystem size used avail use% mount
        if test (count $disk_parts) -ge 5
            set -a info_lines disk "$disk_parts[3] / $disk_parts[2] ($disk_parts[5])"
        end
    end

    # Battery (laptops)
    if test "$os_type" = Darwin
        if command -q pmset
            set -l batt (pmset -g batt 2>/dev/null | grep -o '[0-9]*%' | head -1)
            if test -n "$batt"
                set -l state ""
                if pmset -g batt 2>/dev/null | grep -q 'AC Power'
                    set state " [Charging]"
                end
                set -a info_lines battery "$batt$state"
            end
        end
    else
        set -l bat_path ""
        for p in /sys/class/power_supply/BAT*
            if test -d "$p"
                set bat_path "$p"
                break
            end
        end
        if test -n "$bat_path"
            set -l cap
            set -l status
            read cap <"$bat_path/capacity" 2>/dev/null
            read status <"$bat_path/status" 2>/dev/null
            if test -n "$cap"
                set -a info_lines battery "$cap% [$status]"
            end
        end
    end

    # Locale
    if test -n "$LANG"
        set -a info_lines locale "$LANG"
    end

    # Color palette
    set -a info_lines blank ""
    set -a info_lines colors_normal ""
    set -a info_lines colors_bright ""

    # ── Build Label Map ─────────────────────────────────────────────────

    set -l label_color (set_color magenta)
    set -l reset (set_color normal)

    function _fishfetch_label -a key value label_color reset
        switch $key
            case title;    echo "$value"
            case separator; echo "$value"
            case os;       echo $label_color"OS"$reset": $value"
            case host;     echo $label_color"Host"$reset": $value"
            case kernel;   echo $label_color"Kernel"$reset": $value"
            case uptime;   echo $label_color"Uptime"$reset": $value"
            case shell;    echo $label_color"Shell"$reset": $value"
            case terminal; echo $label_color"Terminal"$reset": $value"
            case de;       echo $label_color"DE"$reset": $value"
            case wm;       echo $label_color"WM"$reset": $value"
            case cpu;      echo $label_color"CPU"$reset": $value"
            case gpu;      echo $label_color"GPU"$reset": $value"
            case memory;   echo $label_color"Memory"$reset": $value"
            case disk;     echo $label_color"Disk (/)"$reset": $value"
            case battery;  echo $label_color"Battery"$reset": $value"
            case locale;   echo $label_color"Locale"$reset": $value"
            case blank;    echo ""
            case colors_normal
                set -l block "███"
                printf "%s%s%s%s%s%s%s%s%s\n" \
                    (set_color black)$block \
                    (set_color red)$block \
                    (set_color green)$block \
                    (set_color yellow)$block \
                    (set_color blue)$block \
                    (set_color magenta)$block \
                    (set_color cyan)$block \
                    (set_color white)$block \
                    (set_color normal)
            case colors_bright
                set -l block "███"
                printf "%s%s%s%s%s%s%s%s%s\n" \
                    (set_color brblack)$block \
                    (set_color brred)$block \
                    (set_color brgreen)$block \
                    (set_color bryellow)$block \
                    (set_color brblue)$block \
                    (set_color brmagenta)$block \
                    (set_color brcyan)$block \
                    (set_color brwhite)$block \
                    (set_color normal)
        end
    end

    # ── Build output lines ──────────────────────────────────────────────

    set -l rendered
    set -l i 1
    while test $i -le (count $info_lines)
        set -l key $info_lines[$i]
        set -l val $info_lines[(math $i + 1)]
        set -a rendered (_fishfetch_label $key $val $label_color $reset)
        set i (math $i + 2)
    end

    # ── ASCII Art ───────────────────────────────────────────────────────

    set -l c1 (set_color cyan)
    set -l c2 (set_color brblue)
    set -l r (set_color normal)

    set -l art
    set -a art "$c1                 ___"
    set -a art "$c1  ___======____=$c2---=$c1)"
    set -a art "$c1/T            \\_$c2--===$c1)"
    set -a art "$c1""[ \\ $c2(O)   $c1\\~    \\_$c2-==$c1)"
    set -a art "$c1 \\      / )J$c2~~    $c1\\$c2-=$c1)"
    set -a art "$c1  \\\\___/  )JJ$c2~~~   $c1\\)"
    set -a art "$c1   \\_____/JJJ$c2~~~~    $c1\\"
    set -a art "$c1   $c2/ $c1\\  $c2, \\"$c1"J$c2~~~~~     \\"
    set -a art "$c1  (-$c2\\)$c1\\=$c2|\\\\\\~~~~       "$c2"L__"
    set -a art "$c1  $c2($c1\\$c2)  (\\\\\\)"$c1"_           $c2\\==__"
    set -a art "$c1   \\V    $c2\\\\$c1\\) ==$c2=_____   \\\\\\\\\\\\"
    set -a art "$c1          \\V)     \\_) $c2\\\\\\\\JJ\\J\\)"
    set -a art "$c1                      /"$c2"J\\J"$c1"T\\"$c2"JJJ"$c1"J)"
    set -a art "$c1                      (J"$c2"JJ"$c1"| \\UUU)"
    set -a art "$c1                       (UU)"
    set -a art "$r"

    set -l art_width 36

    # ── Render Side by Side ─────────────────────────────────────────────

    set -l total_lines (count $art)
    if test (count $rendered) -gt $total_lines
        set total_lines (count $rendered)
    end

    echo ""
    for i in (seq $total_lines)
        set -l art_line ""
        if test $i -le (count $art)
            set art_line $art[$i]
        end
        set -l info_line ""
        if test $i -le (count $rendered)
            set info_line $rendered[$i]
        end

        # Pad art to fixed width (using visible character width)
        set -l stripped (string replace -ra '\e\[[^m]*m' '' "$art_line")
        set -l visible_len (string length "$stripped")
        set -l padding (string repeat -n (math "max(0, $art_width - $visible_len)") ' ')

        printf "  %s%s  %s\n" "$art_line" "$padding" "$info_line"
    end
    echo ""

    # Clean up
    if test -n "$_ff_tmpdir" -a -d "$_ff_tmpdir"
        rm -rf $_ff_tmpdir
    end
    functions -e _fishfetch_label
end

#
# Helper: format seconds into human-readable uptime string.
#
function _fishfetch_format_uptime -a secs
    set -l days (math "floor($secs / 86400)")
    set -l hours (math "floor($secs % 86400 / 3600)")
    set -l mins (math "floor($secs % 3600 / 60)")
    set -l parts
    if test $days -gt 0
        set -a parts "$days days"
    end
    if test $hours -gt 0
        set -a parts "$hours hours"
    end
    set -a parts "$mins mins"
    string join ", " $parts
end
