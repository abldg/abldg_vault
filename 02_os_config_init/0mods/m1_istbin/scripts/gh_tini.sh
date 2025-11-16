#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: gh_tini.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 16:31:28
## VERS: 1.0.0
##==================================----------==================================

# https://github.com/krallin/tini/releases/download/v0.19.0/tini-static-amd64

shfn::istbin::tini() {
  : ${CHDIR:="$HOME/.cache/osci"}
  : ${GHCDN:="https://ghfast.top"}
  : ${ARIDX:="${SHV_PLAT_INDEX:-0}"}
  ###fetch-hashcode-and-filename
  local alst=(amd64 arm64 armhf i386)
  local atmp=${alst[$ARIDX]} && [ X${#atmp} = X0 ] && atmp=${alst}
  ###
  local repown='krallin/tini'
  local apiurl="https://api.github.com/repos/$repown/releases/latest"
  local pjqone='.assets[]'
  pjqone+='|select(.name|match("tini-static-'$atmp'.sha256sum$"))'
  pjqone+='|"'${GHCDN}'/"+.browser_download_url'
  local hashfile_url=$(curl -4sSL $apiurl | jq -r "$pjqone")
  set -- $(curl -4sSL $hashfile_url) && [ $# -ne 2 ] && exit 1
  ###fetch-file-and-install
  local hash_expect=$1
  : ARG1:=file_cached, ARG2=file_dlurl, ARG3=installed_filepath
  set -- $CHDIR/$2 ${hashfile_url%/*}/$2 /usr/local/bin/tini
  mkdir -p $CHDIR ${3%/*} 2>/dev/null
  ##
  while true; do
    if [ -e $1 ]; then
      if [ X$(sha256sum $1 | awk '{printf $1}') = X$hash_expect ]; then
        install -m 755 $1 $3 && break
      fi
      rm -f $1 && sleep 3
    fi
    curl -#4fSLo $1 $2
  done
}
