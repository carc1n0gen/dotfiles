#
# Automatically extract common archive formats into a directory named after the archive.
#
function extract
    argparse 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: extract [options] <archive>"
        echo ""
        echo "Automatically extract common archive formats into a directory named after the archive."
        echo ""
        echo "Supported formats:"
        echo "  .tar.gz, .tgz, .tar.bz2, .tbz2, .tar.xz, .txz"
        echo "  .tar.zst, .tar, .gz, .bz2, .xz, .zst"
        echo "  .zip, .rar, .7z, .Z"
        echo ""
        echo "Options:"
        echo "  -h, --help    Show this help message"
        return 0
    end

    if test (count $argv) -eq 0
        echo "Usage: extract <archive>"
        return 1
    end

    set -l file $argv[1]

    if not test -f $file
        echo "extract: '$file' is not a file."
        return 1
    end

    # Strip extensions to get the output directory name
    set -l base (basename $file)
    set -l dir (string replace -r '\.(tar\.gz|tar\.bz2|tar\.xz|tar\.zst|tgz|tbz2|txz|tar|gz|bz2|xz|zst|zip|rar|7z|Z)$' '' $base)

    if test -d $dir
        echo "extract: directory '$dir' already exists."
        return 1
    end

    mkdir -p $dir

    switch $file
        case '*.tar.gz' '*.tgz'
            tar -xzf $file -C $dir
        case '*.tar.bz2' '*.tbz2'
            tar -xjf $file -C $dir
        case '*.tar.xz' '*.txz'
            tar -xJf $file -C $dir
        case '*.tar.zst'
            tar -x --zstd -f $file -C $dir
        case '*.tar'
            tar -xf $file -C $dir
        case '*.gz'
            gunzip -c $file > $dir/(string replace -r '\.gz$' '' $base)
        case '*.bz2'
            bunzip2 -c $file > $dir/(string replace -r '\.bz2$' '' $base)
        case '*.xz'
            unxz -c $file > $dir/(string replace -r '\.xz$' '' $base)
        case '*.zst'
            unzstd $file -o $dir/(string replace -r '\.zst$' '' $base)
        case '*.zip'
            unzip $file -d $dir
        case '*.rar'
            if command -q unrar
                unrar x $file $dir/
            else if command -q rar
                rar x $file $dir/
            else
                rmdir $dir
                echo "extract: unrar or rar is required to extract '$file'."
                return 1
            end
        case '*.7z'
            if command -q 7z
                7z x $file -o$dir
            else
                rmdir $dir
                echo "extract: 7z is required to extract '$file'."
                return 1
            end
        case '*.Z'
            uncompress -c $file > $dir/(string replace -r '\.Z$' '' $base)
        case '*'
            rmdir $dir
            echo "extract: unsupported format for '$file'."
            return 1
    end

    echo "Extracted to $dir/"
end
