#
# Wrapper around fishsay that uses a thought bubble. Accepts all the same
# flags as fishsay. Equivalent to: fishsay --think [args]
#
function fishthink
    fishsay --think $argv
end
