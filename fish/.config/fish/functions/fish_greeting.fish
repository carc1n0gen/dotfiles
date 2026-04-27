#
# If fortune and cowsay are available, use them for random quote in a random
# cow greeting, otherwise print an ascii fish greeting.
#
function fish_greeting
    if command -q fortune && functions -q fishsay
        fortune -s | fishsay -r
    else if command -q fortune && command -q cowsay
        fortune -s | cowsay -r
    else if functions -q fishsay
        fishsay -r "Welcome to Fish! The friendly interactive shell."
    else
        echo ' --------------------------------------------------
< Welcome to Fish! The friendly interactive shell. >
 --------------------------------------------------
    \
     \     /|
         _/ |
      ,-´    `-:..-´/
     : o )      _  (
     "`-. ..,--; `-.\
         `\''
    end
end
