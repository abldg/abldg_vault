#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: 02_ghrel_cmake.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================
shfn::istbin::cmake() {
  : ${CHDIR:="$HOME/.cache/osci"}
  : ${GHCDN:="https://ghfast.top"}
  : ${ARIDX:="${SHV_PLAT_INDEX:-0}"}
  ###fetch-hashcode-and-filename
  local alst=(x86_64 aarch64)
  local atmp=${alst[$ARIDX]} && [ X${#atmp} = X0 ] && atmp=${alst}
  ###
  local repown='Kitware/CMake'
  local apiurl="https://api.github.com/repos/$repown/releases/latest"
  local pjqone='.assets[]|select(.name|match("linux-'"$atmp"'.sh$"))'
  pjqone+='|.digest+" '${GHCDN}'/"+.browser_download_url'
  set -- $(curl -4sSL $apiurl | jq -r "$pjqone")
  [ $# -ne 2 ] && exit 1
  ###fetch-file-and-install
  local hash_expect=${1#sha256:}
  : ARG1:=file_cached, ARG2=file_downloadurl, ARG3=installed_filepath
  set -- ${CHDIR%/}/${2##*/} $2 /usr/local && mkdir -p $CHDIR $3 2>/dev/null
  ##
  while true; do
    if [ -e $1 ]; then
      if [ X$(sha256sum $1 | awk '{printf $1}') = X$hash_expect ]; then
        bash $1 --prefix=$3 --exclude-subdir --skip-license && break
      fi
      rm -f $1 && sleep 3
    fi
    curl -#4fSLo $1 $2
  done
}
