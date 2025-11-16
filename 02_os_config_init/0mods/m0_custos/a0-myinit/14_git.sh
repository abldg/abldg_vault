#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: 14_git.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
alias gii='[ -d .git ] || git init'
###------------
alias gcl='git clone'
alias gclb='git clone --bare'
alias gclr='git clone --recursive'
alias gcl1='git clone --depth=1'
###------------
alias gac='git add'
alias gad='git add .'
alias gaf='git add . -f'
# alias gadf='git add . -f'
alias gada='git add -A'
alias gadp='git add -P'
###------------
alias gco='git checkout'
alias gwc='git whatchanged'
alias gwf='git clean -fdx'
alias gwx='git clean -fdX'
alias gechs='git config --global credential.helper store'
###------------
alias gst='git status 2>/dev/null'
alias gsts='git status -s 2>/dev/null'
alias gstp='git status --porcelain 2>/dev/null'
alias gsmur='git submodule update --init --recursive 2>/dev/null'
###------------
alias gt='git tag'
alias gm='git merge'
alias grp='git pull'
alias gpr='git pull --rebase'
alias gpp='git pull && git push'
alias grmc='git rm --cached'
alias gtdn='git pull --tags'
alias gtup='git push --tags'
alias grpo='git remote prune origin'
###------------
alias gnew='git log HEAD@{1}..HEAD@{0}'
alias glg='git log --graph --abbrev-commit '
alias glo='git log --oneline'
alias gll='tig'
###------------
alias gdf='git diff'
alias gdfc='git diff --cached'
###------------
alias gca='git commit -v -a'
alias gci='git commit --interactive'
alias gcaa='git commit -a --amend -C HEAD'
alias gcma='git commit --amend'
alias gcpk='git cherry-pick'
###------------
alias gb='git branch'
alias gba='git branch -a'
alias gbt='git branch --track'
alias gbu='git branch -u'
alias gbv='git branch -vv'
###------------
alias gbr='git symbolic-ref -q --short HEAD'
alias grd='git remote remove origin'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
gar() {
  [ ! -d .git ] && return
  local _n=${1:-${PWD##*/}}
  _n=${_n##.}
  git archive --format=tar.gz --prefix=${_n}/ -o ${_n}.tgz ${2:-HEAD}
}
gsh() {
  local xopt="HEAD"
  [ ${#1} -ge 1 ] && xopt="HEAD~$1"
  eval "git show $xopt"
}
gnr() {
  local b="$(git symbolic-ref -q --short HEAD 2>/dev/null)"
  [ ${#b} -ge 1 ] && git branch --set-upstream-to=${1:-origin}/$b $b
}
gbd() {
  [ "X" = "X$1" ] && return
  local cb="$(git symbolic-ref -q --short HEAD 2>/dev/null)"
  [ ${#cb} -ge 1 ] && [ "X$cb" != "X$1" ] &&
    git branch | awk '!/remotes/&&/'"$1"'/' |
    xargs -n1 -i@ git branch -D @ 2>/dev/null
}
gcm() {
  case $1 in
  zq | ZQ) shift && git commit -m "new: $*" ;;
  fix | fx | xf | XF | FIX) shift && git commit -m "fix: $*" ;;
  feat | ft | FEAT) shift && git commit -m "feat: $*" ;;
  todo | td | TODO) shift && git commit -m "todo: $*" ;;
  init | ii | INIT) shift && git commit -m "init: $*" ;;
  "") git commit ;;
  *) git commit -m "$*" ;;
  esac
}
grh() {
  case $1 in
  "") : ;;
  -[0-9]*) git reset --hard HEAD${1/-/\~} ;;
  *) git checkout -- $@ ;;
  esac
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
glb() {
  local curnme=${PWD##*/}
  local lurl=${LBASE:-$HOME/.config/gitrepobak}/${curnme##.}.git
  local rurl=${1:-$(git remote -v | tail -1 | awk '{print $2}')}

  if [ ${#rurl} -ge 1 ] && [ X${#lurl} != X${#rurl} ]; then
    rm -rf ${lurl} 2>/dev/null
    git clone --bare ${rurl} ${lurl}
  fi
  [ -d ${lurl} ] || git clone --bare . ${lurl}
  git remote remove origin
  git remote add origin ${lurl}
  [ ${#rurl} -ge 1 ] && git remote set-url --add origin ${rurl}
  git push --set-upstream origin $(git symbolic-ref -q --short HEAD)
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
grv() {
  local xou=$(git remote get-url ${RMTNME:-origin})
  case $1 in
  -a) git remote -v | column -t ;;
  -r) echo $xou ;;
  *) {
    if [ X0 != X${#xou} ]; then
      echo $xou | sed -r 's#^git@([^:]+):/?#https://\1/#'
    fi
  } ;;
  esac #2>/dev/null
}
alias grva='grv -a'
alias grvr='grv -r'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
gra() {
  local rmtnme=${2:-origin}
  local rmturl=$(git remote get-url ${rmtnme} 2>/dev/null)
  if [ X0 = X${#rmturl} ]; then
    git remote add ${rmtnme} $1
  else
    git remote set-url --add ${rmtnme} $1
  fi
}
