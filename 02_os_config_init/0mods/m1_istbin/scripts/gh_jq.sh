#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: gh_jq.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================
shfn::istbin::jq() {
  : ${CHDIR:="$HOME/.cache/osci"}
  : ${GHCDN:="https://ghfast.top"}
  : ${ARIDX:="${SHV_PLAT_INDEX:-0}"}
  ###get [sha256sums.txt]
  # https://github.com/jqlang/jq/releases/download/jq-1.8.1/jq-linux-amd64
  local alst=(amd64 arm64 armhf i386)
  local atmp=${alst[$ARIDX]} && [ X${#atmp} = X0 ] && atmp=${alst}
  local avrn="${SHV_VERSION_JQ:-1.8.1}"
  local repown='jqlang/jq'
  local dlurl=
  if [ X = X$(command -v jq) ]; then
    dlurl="${GHCDN}/https://github.com/$repown/releases/download"
    dlurl+="/jq-$avrn/sha256sum.txt"
    set -- $(curl -4sfSL $dlurl | awk '/linux/&&/'${atmp}'$/')
    [ $# -ne 2 ] && exit 1
    set -- $1 ${dlurl%/*}/$2
  else
    local apiurl="https://api.github.com/repos/$repown/releases/latest"
    local pjqone='.assets[]|select(.name|match("linux-'${atmp}'$"))'
    pjqone+='|.digest+" '${GHCDN}'/"+.browser_download_url'
    set -- $(curl -4sSL $apiurl | jq -r "$pjqone")
  fi
  ###fetch-hashcode-and-filename
  [ $# -ne 2 ] && exit 1
  ###fetch-file-and-install
  local hash_expect=${1#sha256:}
  : ARG1:=file_cached, ARG2=file_downloadurl, ARG3=installed_filepath
  set -- $CHDIR/${2##*/} $2 /usr/local/bin/jq
  mkdir -p $CHDIR ${3%/*} 2>/dev/null
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
