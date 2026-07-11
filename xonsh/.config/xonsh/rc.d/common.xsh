#
# Common shell aliases
#

# --- Listing -----------------------------------------------------------------
aliases['ll'] = 'ls -lh --color=auto'
aliases['la'] = 'ls -lAh --color=auto'
aliases['l']  = 'ls -CF --color=auto'
aliases['lt'] = 'ls -lhtr --color=auto'       # sort by time, newest last
aliases['lS'] = 'ls -lhSr --color=auto'       # sort by size, largest last

# --- Navigation --------------------------------------------------------------
aliases['..']   = 'cd ..'
aliases['...']  = 'cd ../..'
aliases['....'] = 'cd ../../..'

# --- Safety / Confirmation ---------------------------------------------------
aliases['cp'] = 'cp -iv'
aliases['mv'] = 'mv -iv'
aliases['rm'] = 'rm -Iv'       # -I prompts once before removing >3 files
aliases['ln'] = 'ln -iv'

# --- Mkdir / Dirs ------------------------------------------------------------
aliases['mkdir'] = 'mkdir -pv'

# --- Grep --------------------------------------------------------------------
aliases['grep']  = 'grep --color=auto'
aliases['egrep'] = 'grep -E --color=auto'
aliases['fgrep'] = 'grep -F --color=auto'

# --- Disk / Space ------------------------------------------------------------
aliases['df']  = 'df -h'
aliases['du']  = 'du -h'
aliases['dus'] = 'du -sh'      # summary of current directory
aliases['dua'] = 'du -sh *'    # size of each item in current directory

# --- Process / System --------------------------------------------------------
aliases['psg'] = 'ps aux | grep -v grep | grep'
aliases['top'] = 'btop'

# --- Networking --------------------------------------------------------------
aliases['ip']    = 'ip --color=auto'
aliases['myip']  = 'curl -s https://ifconfig.me && echo'
aliases['ports'] = 'ss -tulnp'
aliases['ping']  = 'ping -c 5'

# --- Clipboard (Wayland) -----------------------------------------------------
aliases['pbcopy']  = 'wl-copy'
aliases['pbpaste'] = 'wl-paste'

# --- Archives ----------------------------------------------------------------
aliases['untar'] = 'tar -xvf'
aliases['mktar'] = 'tar -cvf'
aliases['mktgz'] = 'tar -czvf'

# --- Git (short) -------------------------------------------------------------
aliases['g']     = 'git'
aliases['gst']   = 'git status'
aliases['gd']    = 'git diff'
aliases['gds']   = 'git diff --staged'
aliases['glog']  = 'git log --oneline --decorate --graph'
aliases['ga']    = 'git add'
aliases['gaa']   = 'git add --all'
aliases['gap']   = 'git add --patch'
aliases['gc']    = 'git commit'
aliases['gcm']   = 'git commit -m'
aliases['gcam']  = 'git commit -a -m'
aliases['gca']   = 'git commit --amend'
aliases['gcane'] = 'git commit --amend --no-edit'
aliases['gb']    = 'git branch'
aliases['gba']   = 'git branch -a'
aliases['gbd']   = 'git branch -d'
aliases['gbD']   = 'git branch -D'
aliases['gco']   = 'git checkout'
aliases['gcob']  = 'git checkout -b'
aliases['gsw']   = 'git switch'
aliases['gswc']  = 'git switch -c'
aliases['gp']    = 'git push'
aliases['gpf']   = 'git push --force-with-lease'
aliases['gpu']   = 'git push -u origin HEAD'
aliases['gl']    = 'git pull'
aliases['glr']   = 'git pull --rebase'
aliases['gf']    = 'git fetch'
aliases['gfa']   = 'git fetch --all --prune'
aliases['grb']   = 'git rebase'
aliases['grbi']  = 'git rebase -i'
aliases['grbc']  = 'git rebase --continue'
aliases['grba']  = 'git rebase --abort'
aliases['gsta']  = 'git stash push'
aliases['gstp']  = 'git stash pop'
aliases['gstl']  = 'git stash list'
aliases['gstd']  = 'git stash drop'
aliases['grs']   = 'git restore'
aliases['grss']  = 'git restore --staged'
aliases['grh']   = 'git reset HEAD'
aliases['grhh']  = 'git reset HEAD --hard'
aliases['gcp']   = 'git cherry-pick'

# --- Misc / Quality of Life --------------------------------------------------
aliases['c']     = 'clear'
aliases['h']     = 'history'
aliases['open']  = 'xdg-open'
aliases['watch'] = 'watch -n1'
aliases['path']  = "echo $PATH | tr ':' '\\n'"
aliases['now']   = 'date +"%Y-%m-%d %H:%M:%S"'
aliases['week']  = 'date +%V'

# --- Sudo convenience --------------------------------------------------------
aliases['please'] = 'sudo'
aliases['pls'] = 'sudo'
aliases['pacin']  = 'sudo pacman -S'
aliases['pacup']  = 'sudo pacman -Syu'
aliases['pacrem'] = 'sudo pacman -Rns'
aliases['pacss']  = 'pacman -Ss'
aliases['pacqi']  = 'pacman -Qi'
