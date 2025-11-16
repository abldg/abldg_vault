#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: gh_ttyd.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================
shfn::istbin::ttyd() {
  : ${CHDIR:="$HOME/.cache/osci"}
  : ${GHCDN:="https://ghfast.top"}
  : ${ARIDX:="${SHV_PLAT_INDEX:-0}"}
  ###fetch-hashcode-and-filename
  local alst=(x86_64 aarch64 armhf i686 arm)
  local atmp=${alst[$ARIDX]} && [ X${#atmp} = X0 ] && atmp=${alst}
  ###
  local repown='tsl0922/ttyd'
  local apiurl="https://api.github.com/repos/$repown/releases/latest"
  local pjqone='.assets[]'
  pjqone+='|select(.name|match("SHA256SUMS$"))'
  pjqone+='|" '${GHCDN}'/"+.browser_download_url'
  local hashfile_url=$(curl -4sSL $apiurl | jq -r "$pjqone")
  set -- $(curl -4sSL $hashfile_url | awk '/ttyd.'"$atmp"'$/')
  [ $# -ne 2 ] && exit 1
  ###fetch-file-and-install
  local hash_expect=$1
  : ARG1:=file_cached, ARG2=file_dlurl, ARG3=installed_filepath
  set -- ${CHDIR}/${2}-$(echo $hashfile_url | awk -F'/' '{print $(NF-1)}') \
    ${hashfile_url%/*}/$2 /usr/local/bin/ttyd
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
