#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: gh_dkc.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-16 14:24:06
## VERS: 1.0.2
##==================================----------==================================

#https://github.com/docker/compose/releases/download
#/v2.40.0/docker-compose-linux-x86_64

shfn::istbin::dkc() {
  : ${CHDIR:="$HOME/.cache/osci"}
  : ${GHCDN:="https://ghfast.top"}
  : ${ARIDX:="${SHV_PLAT_INDEX:-0}"}
  ###fetch-hashcode-and-filename
  local alst=(x86_64 aarch64 armv6 armv7 ppc64le riscv64 s390x)
  local atmp=${alst[$ARIDX]} && [ X${#atmp} = X0 ] && atmp=${alst}
  ###
  local repown='docker/compose'
  local apiurl="https://api.github.com/repos/$repown/releases/latest"
  local pjqone='.assets[]'
  pjqone+='|select(.name|match("linux-'$atmp'$"))'
  pjqone+='|.digest+" '${GHCDN}'/"+.browser_download_url'
  set -- $(curl -4sSL $apiurl | jq -r "$pjqone") && [ $# -ne 2 ] && exit 1
  ###fetch-file-and-install
  local hash_expect=${1#sha256:}
  : ARG1:=file_cached, ARG2=file_dlurl
  set -- ${CHDIR}/${2##*/} $2 && mkdir -p $CHDIR 2>/dev/null
  ##
  while true; do
    if [ -e $1 ]; then
      if [ X$(sha256sum $1 | awk '{printf $1}') = X$hash_expect ]; then
        set -- $1 /usr/libexec/docker/cli-plugins && mkdir -p $2 2>/dev/null
        [ -e $1 ] && install -m 755 $1 $2/docker-compose
        break
      fi
      rm -f $1 && sleep 3
    fi
    curl -#4fSLo $1 $2
  done
}
