#
# If fortune and cowsay are available, use them for random quote in a random
# cow greeting, otherwise print an ascii fish greeting.
#
function fish_greeting
    if command -q fortune && command -q cowsay
        fortune -s | cowsay -r
    else
        echo ' __________________________________________________
< Welcome to Fish! The friendly interactive shell. >
 --------------------------------------------------
  \
   \
         /\
         \.\_
\`-\..:-`    `-.
 )  _       ( o :
/.-` ;--,....-"`
          `\''
    end
end
