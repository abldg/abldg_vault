#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: lg_nodejs.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================
shfn::lang::nodejs() {
  : ${CHDIR:="$HOME/.cache/osci"}
  # : ${GHCDN:="https://ghfast.top"}
  : ${ARIDX:="${SHV_PLAT_INDEX:-0}"}
  local alst=(x64 arm64 armv7l s390x)
  local atmp=${alst[$aidx]} && [ X${#atmp} = X0 ] && atmp=${alst}
  ###get-lts-latest-releases-version-str
  local pjqone='first(.[]|select((.lts!=false)'
  pjqone+='and(.version|match("v'${SHV_MJN_NODEJS:-22}'"))'
  pjqone+=')|.version)'
  set -- $(curl -4sfL https://nodejs.org/dist/index.json | jq -r "$pjqone")
  [ $# -ne 1 ] && exit 1
  ###get-hashcode-and-download-url-from-tsinghua-mirror
  set -- "https://mirrors.ustc.edu.cn/node/$1"
  local awkone='/linux-'${atmp}'.tar.gz$/{printf("%s '$1'/%s\n",$1,$2)}'
  set -- $(curl -4sfL $1/SHASUMS256.txt | awk "$awkone")
  [ $# -ne 2 ] && exit 1
  ###fetch-file-and-install
  mpt::install_tgz() {
    set -- $1 /usr/local && mkdir -p $2 2>/dev/null
    cd $(mktemp -dt myt_inst_nodejs.XXXXXX) && bktdir=$PWD
    ###///////////////////////////////////////////////////////
    tar -zxf $1 --no-same-permissions --no-same-owner --strip-components=1
    cp -rf [bils]*/ $2/
    ###///////////////////////////////////////////////////////
    cd && rm -rf $bktdir
    ###///////////////////////////////////////////////////////
    {
      echo "prefix=$HOME/.local/npm_global"
      echo 'registry=https://registry.npmmirror.com'
    } >$HOME/.npmrc && mkdir -p $HOME/.local/npm_global 2>/dev/null
    hash -r && npm config ls
  }

  local hash_expect=$1
  : ARG1:=file_cached, ARG2=file_downloadurl
  set -- ${CHDIR%/}/${2##*/} $2 && mkdir -p $CHDIR 2>/dev/null
  ##
  while true; do
    if [ -e $1 ]; then
      if [ X$(sha256sum $1 | awk '{printf $1}') = X$hash_expect ]; then
        mpt::install_tgz $1 && break
      fi
      rm -f $1 && sleep 3
    fi
    curl -#4fSLo $1 $2
  done
}
