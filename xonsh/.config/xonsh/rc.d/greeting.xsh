if !(which fortune 2>/dev/null).returncode == 0 and !(which cowsay 2>/dev/null).returncode == 0:
    fortune -s | cowsay -r
else:
    print("Welcome to xonsh!")
