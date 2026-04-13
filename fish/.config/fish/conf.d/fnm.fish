#
# If fnm is installed, set up the environment for it.
#
if command -q fnm
    fnm env --use-on-cd --shell fish | source
end
