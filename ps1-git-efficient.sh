#!/bin/sh
ps1git_efficient() {
  local fmt; fmt=${1:-' (%s)'}
  local gsp
  if "${ps1git_efficient_status:-true}"; then
    gsp=$(git --no-optional-locks status --porcelain -s -b -unormal 2>/dev/null)
  else
    gsp="## $(git branch --show-current 2>/dev/null)...<REMOTE>"  # emulate git status
  fi
  if [ -z "$gsp" ]; then return 0; fi
  local nl='
';
  local gs1= gsa= gsb= gsu= gsm= gsbr='UNKNOWN'
  gsb=${ps1git_efficient_fmt_b:-'<'}
  gsa=${ps1git_efficient_fmt_a:-'>'}
  gsu=${ps1git_efficient_fmt_u:-'?'}
  gsm=${ps1git_efficient_fmt_m:-'*'}
  gs1=${gsp%%"$nl"*}  # first line
  case "$gs1" in ('## '*) gsbr=${gs1#'## '}; gsbr=${gsbr%%'...'*}; gsbr=${gsbr%%' '*} ;; esac
  case "$gsp" in (*"${nl}"'?'*)    ;; (*) gsu= ;; esac
  case "$gs1" in (*'['*ahead*']')  ;; (*) gsa= ;; esac
  case "$gs1" in (*'['*behind*']') ;; (*) gsb= ;; esac
  case "$gsp" in (*"${nl}"?[MTADRCU]*|*"${nl}"[MTADRCU]*) ;; (*) gsm= ;; esac
  local gs; gs=$gsu$gsb$gsa$gsm$gsbr
  [ -z "$gs" ] || printf "$fmt" "$gs"
}

if [ "${1:-}" = --ps1_print ]; then shift; ps1git_efficient "$@"; fi

## (POSIX) sh '.' unconditionally passes through "$@" of including script
## (at the point where '.' occurs)
## '.' ignores any parameters after included script name
## To source this AND control args, call '.' from a function
## 'source' isn't a sh command; it's subtly different in shells that have it
