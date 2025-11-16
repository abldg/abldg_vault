#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: bv_kubectl.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-16 10:06:44
## VERS: 0.1
##==================================----------==================================

shfn::istbin::cnmir::kubectl() {
  : ${ARIDX:="${SHV_PLAT_INDEX:-0}"}
  local alst=(amd64 arm64 arm 386)
  local atmp=${alst[$ARIDX]} && [ X${#atmp} = X0 ] && atmp=${alst}
  local repown="kubernetes/kubernetes"
  local apiurl="https://api.github.com/repos/$repown/releases/latest"
  local ltsvrn=$(curl -4sfSL $apiurl | jq -r '.tag_name')
  local hash_url="https://dl.k8s.io/${ltsvrn}/bin/linux/${atmp}/kubectl.sha256"
  local hash_expect=$(curl -4sfSL $hash_url)
  ###
  [ X0 = X${#hash_expect} ] && exit 1
  ###
  set -- linux-${atmp}-${ltsvrn}-kubectl
  if [ Xamd64 = X$atmp ]; then
    #https://rancher-mirror.rancher.cn/kubectl/v1.34.1/linux-amd64-v1.34.1-kubectl
    set -- $CHDIR/${1} https://rancher-mirror.rancher.cn/kubectl/${ltsvrn}/$1
  else
    set -- $CHDIR/${1} ${hash_url%.sha256}
  fi
  ###fetch-file-and-install
  set -- $@ /usr/local/bin/kubectl
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
