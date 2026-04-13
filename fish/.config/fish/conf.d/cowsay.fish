#
# Setup COWPATH to include system and user cow files.
#
if command -q cowsay
    mkdir -p ~/.local/share/cowsay/cows

    set -l cowpaths ~/.local/share/cowsay/cows

    for dir in /opt/homebrew/share/cowsay/cows /usr/share/cowsay/cows /usr/share/cows
        if test -d $dir
            set -a cowpaths $dir
            break
        end
    end

    set -gx COWPATH $cowpaths
end
