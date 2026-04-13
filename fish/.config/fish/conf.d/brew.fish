#
# If homebrew is installed, set up the environment for it.
#
# potential TODO: support intel macs, they use a different directory for brew
#
if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end
