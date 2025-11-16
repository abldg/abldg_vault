#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: istbin_01_cldpods.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================
##https://www.cloudpods.org/docs/getting-started/onpremise/quickstart-virt
doxxxx() {
  ##----------------------------------------------------------------------------
  apt update -y && apt install -y buildah
  ##----------------------------------------------------------------------------
  : ${GHCDN:=https://ghfast.top} ${CHDIR:=$HOME/.cache/osci}
  purl=https://github.com/yunionio/ocboot/archive/refs/tags
  aurl=https://api.github.com/repos/yunionio/ocboot/releases
  vern=$(curl -4Ls $aurl | jq -r '.[0].name')
  sdir=ocboot-$vern
  cahf=$CHDIR/$sdir.tar.gz
  if [ ! -d $sdir ]; then
    if [ ! -e $cahf ]; then
      mkdir -p $CHDIR 2>/dev/null
      curl -sfSLo $cahf $GHCDN/$purl/$vern.tar.gz
    fi
    [ -e $cahf ] && tar -zxf $cahf --no-same-owner --no-same-permissions
  fi
  ##----------------------------------------------------------------------------
  host_ip4=$(ip -4 -j r get 1 | jq -r '.[0].prefsrc')
  cd $sdir && if [[ -e ocboot.sh && X${#host_ip4} != X0 ]]; then
    ./ocboot.sh run.py virt $host_ip4
  fi
}
doxxxx $@
