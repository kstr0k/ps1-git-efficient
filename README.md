# `ps1-git-efficient`

## _Minimalistic shell-prompt `git status` fragment generator_

## What it looks like

From within a `git` repo, the prompt might look like this:
```
hostname dir (<>?*branch)$
```

where the `git` part this script generates has the following components:
* `branch`: current branch (or `HEAD` if detached)
* `<` and `>`: the local branch is ahead and/or behind upstream
* `?`: there are untracked file
* `*`: there are modified tracked files (including conflicts, file-type changes, deleted / added / unmerged files)

## Usage

### Bourne shells (POSIX `sh`, `bash` etc)

```shell
PS1='\h \W$(/path/to/ps1-git-efficient.sh --ps1_print)\$ '

## or load script & function beforehand, combine with other generators
tmploader() { . /path/to/ps1-git-efficient.sh; }; tmploader
PS1='\h \W$(gen1; ps1git_efficient; gen2)\$ '
```

### Large repos

For large `git` repositories, even a single `git status` can be slow (it has to examine recursively the entire repo). Set `ps1git_efficient_status=false` in your shell: `status` will be replaced with a simpler `git` command that only detects and prints the current branch.

### Tweaks

The script / function also accept an additional optional format argument (for the script: *after `--ps1_print`*). The default format is `' (%s)'`. You can customize it, for example to add colors:
```shell
# precompute global format variable, use it in PS1 call
ps1git_efficient_fmt=" ($(tput setaf 1)%s$(tput sgr0))"
PS1='\h \W $(ps1git_efficient "$ps1git_efficient_fmt")\$ '
```

### Fish

TODO: create `.fish` function and use `string`. In the meantime, you could

```fish
# add `ps1-git-efficient.sh --ps1_print` to `fish(_right)_prompt`
# e.g. in Disco prompt: replace other git calls with
set -l vcs = (/path/to/ps1-git-efficient.sh --ps1_print)
```

## Performance

* there is a single call to `git status`
* it uses `--no-optional-locks` to avoid `git`'s habit of opportunistically updating `.git/index` (creating &amp; removing a lock file in the process, even when there are *no changes*) which should *probably* not happen every time you press `<Enter>` in the shell
* string processing uses POSIX shell built-in parameter expansion, without any overhead from external utilities (`sed`, `grep`, `head` etc)
* if you source the script from `.bashrc` or similar, `PS1` can contain a single function call to a single combined generator which calls the `ps1git_efficient` function

Here's an example that optionally prints the exit code from the previous command (if non-zero and not `^C`) and also `git` info (if within a repo):
```shell
# source the script with POSIX-compliant `.`
# wrap `.` in function to avoid "$@" (argv) leakage
tmploader() { . /path/to/ps1-git-efficient.sh; }; tmploader

ps1gen() {
  # process $? status before calling any other commands
  local s=${?#0*}; s=${s#130}; s=${s:+' ?'$s}
  ps1git_efficient
  printf %s "$s"
}
PS1='\h \W$(ps1gen)\$ '  # single subshell for ps1gen()
```

## Copyright

Alin Mr <almr.oss@outlook.com> / MIT license.
