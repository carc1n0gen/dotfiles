#
# Custom Xonsh prompt with Git info, Node version, Python virtualenv, and time display.
#

if $XONSH_INTERACTIVE:
    import os
    import re
    import shutil
    import subprocess
    import time
    from datetime import datetime



    # helpers

    def _strip_colors(s):
        """Remove ANSI escape codes and {COLOR} tokens to measure visible string width."""
        s = re.sub(r"\033\[[0-9;]*m", "", s)
        s = re.sub(r"\{[A-Z_]+\}", "", s)
        return s


    def _short_pwd():
        """Shorten cwd like fish's prompt_pwd (abbreviate intermediate dirs)."""
        path = $PWD.replace($HOME, "~")
        parts = path.split("/")
        return "/".join(
            p[0] if i < len(parts) - 1 and p else p
            for i, p in enumerate(parts)
        )


    def _bg_fetch():
        """Run git fetch in the background with a 5-minute per-repo cooldown."""
        try:
            root = $(git rev-parse --show-toplevel 2>/dev/null).strip()
            if not root:
                return
            stamp = f"/tmp/xonsh_fetch_{root.replace('/', '_')}"
            now = time.time()
            do_fetch = True
            if os.path.exists(stamp):
                try:
                    last = float(open(stamp).read())
                    do_fetch = now - last > 300
                except (ValueError, OSError):
                    pass
            if do_fetch:
                open(stamp, "w").write(str(int(now)))
                subprocess.Popen(
                    ["git", "fetch", "--quiet"],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
        except Exception:
            pass


    # prompt fields

    def _git_info():
        """Git branch and status info matching the fish prompt."""
        try:
            branch = $(git branch --show-current 2>/dev/null).strip()
        except Exception:
            return ""
        if not branch:
            return ""

        nf = "NERD_FONT" in ${...}
        # Symbols - Nerd-Font glyphs when $NERD_FONT is set, plain Unicode otherwise
        branch_sym    = "" if nf else "⎇"
        staged_sym    = "󱇬" if nf else "+"
        unstaged_sym  = "" if nf else "⚑"
        untracked_sym = "󰀦" if nf else "⚠"
        clean_sym     = "" if nf else "✔"
        stash_sym     = "" if nf else "≡"
        up_sym        = "" if nf else "↑"
        down_sym      = "" if nf else "↓"

        # status flags
        status = ""
        try:
            if !(git diff --cached --quiet 2>/dev/null).returncode:
                status += f" {{GREEN}}{staged_sym}"
            if !(git diff --quiet 2>/dev/null).returncode:
                status += f" {{YELLOW}}{unstaged_sym}"
            if $(git ls-files --others --exclude-standard 2>/dev/null).strip():
                status += f" {{RED}}{untracked_sym}"
        except Exception:
            pass
        if not status:
            status = f" {{GREEN}}{clean_sym}"

        # stash
        stash = ""
        try:
            if $(git stash list 2>/dev/null).strip():
                stash = f" {{CYAN}}{stash_sym}"
        except Exception:
            pass

        # background fetch
        _bg_fetch()

        # ahead / behind upstream
        sync = ""
        try:
            upstream_ref = "HEAD...@{upstream}"
            lr = $(git rev-list --left-right --count @(upstream_ref) 2>/dev/null).strip().split()
            if len(lr) == 2:
                a, b = int(lr[0]), int(lr[1])
                if a > 0 and b > 0:
                    sync = f" {{INTENSE_RED}}{up_sym}{a}{down_sym}{b}"
                elif a > 0:
                    sync = f" {{INTENSE_GREEN}}{up_sym}{a}"
                elif b > 0:
                    sync = f" {{INTENSE_YELLOW}}{down_sym}{b}"
        except Exception:
            pass

        return f"{{PURPLE}} ({branch_sym} {branch}{status}{stash}{sync}{{PURPLE}}){{RESET}}"


    def _prompt_icon():
        """Prompt icon coloured by last command's exit status."""
        rtn = $PROMPT_FIELDS["last_return_code"]()
        if not rtn:
            return "{GREEN}@ >{RESET}"
        return "{RED}@ >{RESET}"


    def _node_info():
        """Node.js version, shown only when package.json is present."""
        if os.path.exists("package.json") and shutil.which("node"):
            try:
                v = $(node --version).strip()
                return f"{{INTENSE_BLUE}}⬢{v}{{RESET}} "
            except Exception:
                pass
        return ""




    def _info_line():
        """First prompt line: user@host pwd (git) with right-aligned clock."""
        user_field = $PROMPT_FIELDS["user"]
        user = user_field() if callable(user_field) else user_field
        host_field = $PROMPT_FIELDS["hostname"]
        host = host_field() if callable(host_field) else host_field

        line = f"{{CYAN}}{user}{{RESET}}@{{INTENSE_BLUE}}{host}{{RESET}} {{YELLOW}}{_short_pwd()}{{RESET}}" + _git_info()

        fmt = ${...}.get("FISH_PROMPT_DATE_FORMAT", "%Y-%m-%d %H:%M")
        tstr = datetime.now().strftime(fmt)
        cols = shutil.get_terminal_size().columns
        pad = max(1, cols - len(_strip_colors(line)) - len(tstr))
        clock = f"{{INTENSE_BLACK}}{tstr}{{RESET}}"

        return f"{line}{' ' * pad}{clock}"


    # register fields
    $PROMPT_FIELDS["info_line"] = _info_line
    $PROMPT_FIELDS["prompt_icon"] = _prompt_icon
    $PROMPT_FIELDS["node_info"] = _node_info
    $PROMPT_FIELDS["env_prefix"] = "{INTENSE_BLUE}("
    $PROMPT_FIELDS["env_postfix"] = "){RESET} "

    # prompt layout
    $PROMPT = "\n{info_line}\n{env_name}{node_info}{prompt_icon} "
