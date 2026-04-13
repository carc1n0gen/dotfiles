#
# A bunch of git related abbreviations.
#
if command -q git
    # Basic
    abbr -a g git
    abbr -a gst 'git status'
    abbr -a gd 'git diff'
    abbr -a gds 'git diff --staged'
    abbr -a glog 'git log --oneline --decorate --graph'

    # Add
    abbr -a ga 'git add'
    abbr -a gaa 'git add --all'
    abbr -a gap 'git add --patch'

    # Commit
    abbr -a gc 'git commit'
    abbr -a gcm 'git commit -m'
    abbr -a gcam 'git commit -a -m'
    abbr -a gca 'git commit --amend'
    abbr -a gcane 'git commit --amend --no-edit'

    # Branch
    abbr -a gb 'git branch'
    abbr -a gba 'git branch -a'
    abbr -a gbd 'git branch -d'
    abbr -a gbD 'git branch -D'

    # Checkout / Switch
    abbr -a gco 'git checkout'
    abbr -a gcob 'git checkout -b'
    abbr -a gsw 'git switch'
    abbr -a gswc 'git switch -c'

    # Push / Pull
    abbr -a gp 'git push'
    abbr -a gpf 'git push --force-with-lease'
    abbr -a gpu 'git push -u origin HEAD'
    abbr -a gl 'git pull'
    abbr -a glr 'git pull --rebase'

    # Fetch
    abbr -a gf 'git fetch'
    abbr -a gfa 'git fetch --all --prune'

    # Rebase
    abbr -a grb 'git rebase'
    abbr -a grbi 'git rebase -i'
    abbr -a grbc 'git rebase --continue'
    abbr -a grba 'git rebase --abort'

    # Stash
    abbr -a gsta 'git stash push'
    abbr -a gstp 'git stash pop'
    abbr -a gstl 'git stash list'
    abbr -a gstd 'git stash drop'

    # Restore / Reset
    abbr -a grs 'git restore'
    abbr -a grss 'git restore --staged'
    abbr -a grh 'git reset HEAD'
    abbr -a grhh 'git reset HEAD --hard'

    # Remote
    abbr -a grv 'git remote -v'
    abbr -a gra 'git remote add'

    # Cherry-pick
    abbr -a gcp 'git cherry-pick'
    abbr -a gcpa 'git cherry-pick --abort'
    abbr -a gcpc 'git cherry-pick --continue'

    # Misc
    abbr -a gclean 'git clean -fd'
    abbr -a gignore 'git update-index --assume-unchanged'
    abbr -a gunignore 'git update-index --no-assume-unchanged'
end
