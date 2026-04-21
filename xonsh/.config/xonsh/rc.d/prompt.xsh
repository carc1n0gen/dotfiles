def short_pwd():
    # Replace home dir with ~
    path = $PWD.replace($HOME, "~")
    parts = path.split('/')

    # Shorten all but the last directory to 1 character
    res = [p[0] if i < len(parts) - 1 and p else p for i, p in enumerate(parts)]
    return "/".join(res)

$PROMPT_FIELDS['short_pwd'] = short_pwd

# {gitstatus} is a "super-field" that includes branch and status icons
#$PROMPT = "\n{GREEN}{user}@{hostname} {BOLD_BLUE}{short_pwd}{RESET} {gitstatus} \n{BOLD_BLUE}@{RESET} "

$PROMPT = "\n{GREEN}{user}@{hostname} {BOLD_BLUE}{short_pwd}{RESET} \n{BOLD_BLUE}@{RESET} "

# Optional: Customize the symbols/colors of the git status
$PROMPT_FIELDS['gitstatus.branch'].prefix = "{CYAN}"
$PROMPT_FIELDS['gitstatus.staged'].prefix = "{GREEN}●"
$PROMPT_FIELDS['gitstatus.changed'].prefix = "{YELLOW}+"
