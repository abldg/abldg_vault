#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: bv_helm.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-15 16:57:17
## VERS: 0.1
##==================================----------==================================

shfn::istbin::cnmir::helm() {
  : ${CHDIR:="$HOME/.cache/osci"}
  set -- 'https://rancher-mirror.rancher.cn/helm/get-helm-3.sh'
  set -- ${CHDIR}/${1##*/} $1 && mkdir -p $CHDIR 2>/dev/null
  while true; do
    if [ -e $1 ]; then
      INSTALL_HELM_MIRROR=cn ${MYBASH:-bash -x} $1
      break
    fi
    sleep 3s && curl -4fsSLo $1 $2
  done
}
##//////////////////////////////////////////////////////////////////////////////
shfn::istbin::github::helm() {
  : ${CHDIR:="$HOME/.cache/osci"}
  : ${GHCDN:="https://ghfast.top"}
  : ${ARIDX:="${SHV_PLAT_INDEX:-0}"}
  ###fetch-hashcode-and-filename
  local alst=(amd64 arm64 arm 386 ppc64le riscv64 s390x)
  local atmp=${alst[$ARIDX]} && [ X${#atmp} = X0 ] && atmp=${alst}
  ###
  local repown='helm/helm'
  local apiurl="https://api.github.com/repos/$repown/releases/latest"
  local pjqone='.assets[]'
  pjqone+='|select(.name|match("linux-'$atmp'.tar.gz.sha256sum.asc"))'
  pjqone+='|"https://get.helm.sh/"+.name'
  local hashfile_url=$(curl -4sfSL $apiurl | jq -r "$pjqone" | sed 's|.asc||')
  set -- $(curl -4sfSL $hashfile_url)
  [ $# -ne 2 ] && exit 1
  ###fetch-file-and-install
  mpt::install_tgz() {
    set -- $1 /usr/local/bin/helm
    cd $(mktemp -dt myt_inst_${2##*/}.XXXXXX) && bktdir=$PWD
    ###///////////////////////////////////////////////////////
    tar -zxf $1 --no-same-permissions --no-same-owner --strip-components=1
    mkdir -p ${2%/*} 2>/dev/null
    install -m 755 ${2##*/} $2
    ###///////////////////////////////////////////////////////
    cd && rm -rf $bktdir
  }
  local hash_expect=$1
  : ARG1:=file_cached, ARG2=file_downloadurl
  set -- ${CHDIR%/}/$2 ${hashfile_url%.sha256sum} && mkdir -p $CHDIR 2>/dev/null
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
