#
# If homebrew is installed, set up the environment for it.
#
if p"/opt/homebrew/bin/brew".exists():
    source-bash $(/opt/homebrew/bin/brew shellenv)
