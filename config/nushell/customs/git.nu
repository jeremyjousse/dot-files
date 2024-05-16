##
# Git aliases
##

## Inspired form https://github.com/nushell/nu_scripts/blob/main/aliases/git/git-aliases.nu

# git fetch
export alias gf = git fetch

# git fetch --all --prune
export alias gfa = git fetch --all --prune

# git fetch origin
export alias gfo = git fetch origin

# git pull
export alias gpl = git pull

##
# Git functions
##

# Switch git branches using fzf completion
def gbs [] {
  let branch = (
    git branch |
    split row "\n" |
    str trim |
    where ($it !~ '\*') |
    where ($it != '') |
    str join (char nl) |
    fzf --no-multi
  )
  if $branch != '' {
    git switch $branch
  }
}

# Delete git branches using fzf completion
def gbd [] {
  let branches = (
    git branch |
    split row "\n" |
    str trim |
    where ($it !~ '\*') |
    where ($it != '') |
    str join (char nl) |
    fzf --multi |
    split row "\n" |
    where ($it != '')
  )
  if ($branches | length) > 0 {
    $branches | each { |branch| git branch -d $branch }
    ""
  }
}

# Clean git merged branches
def gbc [] {
    git branch --merged | lines | where ($it != "* master" and $it != "* main") | each {|br| git branch -D ($br | str trim) } | str trim
}

# Show git log in a pretty way
def gl [limit = 10] {
    git log --pretty=%h»¦«%aN»¦«%s»¦«%aD | lines | split column "»¦«" sha1 committer desc merged_at | first ($limit)
}

# View git committer activity as a histogram
def gca [] {
    git log --pretty=%h»¦«%aN»¦«%s»¦«%aD | lines | split column "»¦«" sha1 committer desc merged_at | histogram committer merger | sort-by merger | reverse
}

##
# Git custom completions
##

## inspired from: https://github.com/nushell/nu_scripts/blob/main/custom-completions/git/git-completions.nu

def "nu-complete git remotes" [] {
  ^git remote | lines | each { |line| $line | str trim }
}

def "nu-complete git switch" [] {
  (nu-complete git local branches)
  | parse "{value}"
  | insert description "local branch"
  | append (nu-complete git remote branches nonlocal without prefix
            | parse "{value}"
            | insert description "remote branch")
}

# Yield remote branches *without* prefix which do not have a local counterpart.
# E.g. `upstream/feature-a` as `feature-a` to checkout and track in one command
# with `git checkout` or `git switch`.
def "nu-complete git remote branches nonlocal without prefix" [] {
  # Get regex to strip remotes prefixes. It will look like `(origin|upstream)`
  # for the two remotes `origin` and `upstream`.
  let remotes_regex = (["(", ((nu-complete git remotes | each {|r| [$r, '/'] | str join}) | str join "|"), ")"] | str join)
  let local_branches = (nu-complete git local branches)
  ^git branch -r | lines | parse -r (['^[\* ]+', $remotes_regex, '?(?P<branch>\S+)'] | flatten | str join) | get branch | uniq | where {|branch| $branch != "HEAD"} | where {|branch| $branch not-in $local_branches }
}

# Yield local branches like `main`, `feature/typo_fix`
def "nu-complete git local branches" [] {
  ^git branch | lines | each { |line| $line | str replace '* ' "" | str trim }
}

def "nu-complete git log" [] {
  ^git log --pretty=%h | lines | each { |line| $line | str trim }
}


# Switch between git branches and commits
export extern "git switch" [
  switch?: string@"nu-complete git switch"        # name of branch to switch to
  --create(-c)                                    # create a new branch
  --detach(-d): string@"nu-complete git log"      # switch to a commit in a detached state
  --force-create(-C): string                      # forces creation of new branch, if it exists then the existing branch will be reset to starting point
  --force(-f)                                     # alias for --discard-changes
  --guess                                         # if there is no local branch which matches then name but there is a remote one then this is checked out
  --ignore-other-worktrees                        # switch even if the ref is held by another worktree
  --merge(-m)                                     # attempts to merge changes when switching branches if there are local changes
  --no-guess                                      # do not attempt to match remote branch names
  --no-progress                                   # do not report progress
  --no-recurse-submodules                         # do not update the contents of sub-modules
  --no-track                                      # do not set "upstream" configuration
  --orphan: string                                # create a new orphaned branch
  --progress                                      # report progress status
  --quiet(-q)                                     # suppress feedback messages
  --recurse-submodules                            # update the contents of sub-modules
  --track(-t)                                     # set "upstream" configuration
]
