#
# If fnm is installed, set up the environment for it.
#
if !(which fnm 2>/dev/null).returncode == 0:
    source-bash $(fnm env --shell bash)

    @events.on_chdir
    def _fnm_auto_switch(olddir, newdir, **kwargs):
        if pf"{newdir}/.node-version".exists() or pf"{newdir}/.nvmrc".exists():
            fnm use --silent-if-unchanged
