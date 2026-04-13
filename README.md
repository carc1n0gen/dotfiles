# My Personal Dotfiles

These are my personal dotfiles that I use `stow` to manage. Stow uses the
concept of "packages" to organize your dotfiles. Each package is a directory
that contains the dotfiles you want to manage. When you run `stow`, it creates
symbolic links from the files in the package to the appropriate locations in
your target directory.

**Example directory structure:**

```
dotfiles/
├── cowsay/
│   ├── .local/
│   │   └── share/
│   │       └── cowsay/
│   │           └── cows/
│   │               └── fish.cow
├── fish/
│   ├── .config/
│   │   └── fish/
│   │       └── config.fish
├── hypr/
│   ├── .config/
│   │   └── hypr/
│   │       └── hyprland.conf
├── waybar/
│   ├── .config/
│   │   └── waybar/
│   │       └── config.jsonc
│   │       └── style.css
```

## Installation

To install everything you can clone the repository to your home directory and
run `stow` from the cloned directory:

```bash
git clone https://github.com/carc1n0gen/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow *
```

Or to install specific dotfiles, you can use:

```bash
stow <packge_name>
```

Stow treats current directory as `stow` directory, and the parent directory of
the `stow` directory as the `target` directory. So, in this case, the target
directory is your home directory.

You can clone to a directory of your own choice, and run `stow` from outside
the dotfiles directory with flags to override these defaults. For example:

```bash
git clone https://github.com/carc1n0gen/dotfiles.git ~/My/Custom/Dir/Dotfiles
stow -d ~/My/Custom/Dir/Dotfiles -t ~ *
```

Or again for a single package

```bash
stow -d ~/My/Custom/Dir/Dotfiles -t ~ <package_name>
```
