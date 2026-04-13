#
# Spin up a quick HTTP server in the current directory.
#
function serve
    argparse 'h/help' 'p/port=' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: serve [options]"
        echo ""
        echo "Spin up a quick HTTP server in the current directory."
        echo ""
        echo "Options:"
        echo "  -p, --port PORT    Port to serve on (default: 8000)"
        echo "  -h, --help         Show this help message"
        return 0
    end

    set -l port 8000
    if set -q _flag_port
        if not string match -qr '^[0-9]+$' $_flag_port; or test $_flag_port -lt 1; or test $_flag_port -gt 65535
            echo "Invalid port: $_flag_port. Must be a number between 1 and 65535."
            return 1
        end
        set port $_flag_port
    end

    echo "Serving on http://localhost:$port"
    python3 -m http.server $port
end
