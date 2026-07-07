#
# A cowsay-inspired ASCII art speech bubble generator for xonsh.
# Shell art is defined in ~/.local/share/shellsay/shells/<name>.py files,
# each containing a `the_shell` variable with the ASCII art and {thoughts}
# as the connector placeholder.
#
# Usage: shellsay [-f <name>] [-W <width>] [-n] [-r] [-t] [-l] [-h] [message]
#   If no message is given, reads from stdin.
#
# Options:
#   -f, --file <name>     Use a named shell (default: conch)
#   -r, --random          Pick a random shell
#   -t, --think           Use a thought bubble instead of a speech bubble
#   -W, --wrap <width>    Wrap message at <width> characters (default: 40)
#   -n, --nowrap          Disable word wrapping
#   -l, --list            List available shells
#   -h, --help            Show this help message
#

import argparse
import importlib.util
import os
import random
import sys
import textwrap


def _get_shells_dir():
    """Return the path to the shells directory."""
    data_home = os.environ.get("XDG_DATA_HOME", os.path.expanduser("~/.local/share"))
    return os.path.join(data_home, "shellsay", "shells")


def _list_shells(shells_dir):
    """List all available shell names."""
    names = []
    if os.path.isdir(shells_dir):
        for f in sorted(os.listdir(shells_dir)):
            if f.endswith(".py"):
                names.append(f[:-3])
    return names


def _load_shell(shells_dir, name):
    """Load a shell's art by importing its .py file as a module and reading `the_shell`."""
    shell_file = os.path.join(shells_dir, f"{name}.py")
    if not os.path.isfile(shell_file):
        return None
    spec = importlib.util.spec_from_file_location(name, shell_file)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return getattr(module, "the_shell", None)


def _wrap(message, width):
    """Word-wrap a message into lines, respecting existing newlines."""
    lines = []
    for paragraph in message.split("\n"):
        if paragraph.strip() == "":
            lines.append("")
        else:
            lines.extend(textwrap.wrap(paragraph, width=width, break_long_words=True, break_on_hyphens=False))
    return lines if lines else [""]


def _render_bubble(lines, think=False):
    """Render the speech/thought bubble around the message lines."""
    max_len = max(len(line) for line in lines)
    border = "-" * (max_len + 2)
    num_lines = len(lines)
    result = [f" {border}"]

    for i, line in enumerate(lines):
        padding = " " * (max_len - len(line))
        if think:
            result.append(f"( {line}{padding} )")
        elif num_lines == 1:
            result.append(f"< {line}{padding} >")
        elif i == 0:
            result.append(f"/ {line}{padding} \\")
        elif i == num_lines - 1:
            result.append(f"\\ {line}{padding} /")
        else:
            result.append(f"| {line}{padding} |")

    result.append(f" {border}")
    return "\n".join(result)


def _shellsay(args, stdin=None, think=False):
    """Core implementation shared by shellsay and shellthink."""
    parser = argparse.ArgumentParser(
        prog="shellthink" if think else "shellsay",
        description="A cowsay-inspired ASCII art speech bubble generator.",
        add_help=True,
    )
    parser.add_argument("-f", "--file", default=None, help="Use a named shell (default: conch)")
    parser.add_argument("-r", "--random", action="store_true", help="Pick a random shell")
    parser.add_argument("-t", "--think", action="store_true", default=think, help="Use a thought bubble")
    parser.add_argument("-W", "--wrap", type=int, default=40, help="Wrap message at <width> characters (default: 40)")
    parser.add_argument("-n", "--nowrap", action="store_true", help="Disable word wrapping")
    parser.add_argument("-l", "--list", action="store_true", help="List available shells")
    parser.add_argument("message", nargs="*", help="The message to display")

    try:
        opts = parser.parse_args(args)
    except SystemExit:
        return

    shells_dir = _get_shells_dir()

    # List mode
    if opts.list:
        for name in _list_shells(shells_dir):
            print(name)
        return

    # Gather the message
    if opts.message:
        message = " ".join(opts.message)
    elif stdin is not None:
        message = stdin.read().strip()
    else:
        message = ""

    if not message:
        message = "..."

    # Pick the shell
    available = _list_shells(shells_dir)
    if not available:
        print(f"shellsay: no shells found in {shells_dir}", file=sys.stderr)
        return

    if opts.random:
        shell_name = random.choice(available)
    elif opts.file:
        shell_name = opts.file
    else:
        shell_name = "conch"

    shell_art = _load_shell(shells_dir, shell_name)
    if shell_art is None:
        print(f"shellsay: shell '{shell_name}' not found in {shells_dir}", file=sys.stderr)
        return

    # Word-wrap
    if opts.nowrap:
        lines = message.split("\n")
    else:
        lines = _wrap(message, opts.wrap)

    # Render
    bubble = _render_bubble(lines, think=opts.think)
    connector = "o" if opts.think else "\\"
    creature = shell_art.replace("{thoughts}", connector)

    print(bubble + creature, end="")


@aliases.register("shellsay")
def shellsay(args, stdin=None):
    _shellsay(args, stdin=stdin, think=False)


@aliases.register("shellthink")
def shellthink(args, stdin=None):
    _shellsay(args, stdin=stdin, think=True)
