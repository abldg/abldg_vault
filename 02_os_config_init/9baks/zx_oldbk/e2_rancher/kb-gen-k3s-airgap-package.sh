#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: kb-gen-k3s-airgap-package.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================

xfn_dlget_k3sbin() {
  set -- ${1//,/ }
  while true; do
    [ ! -e $1 ] && curl -#4fSLo $1 $2
    [ -e $1 ] && {
      if [ X$3 = X$(sha256sum $1 | awk '{printf $1}') ]; then
        ##passed-checksum
        mkdir -p ${tbindir:="$pakdir/usr/local/bin"}
        install -m 755 $1 $tbindir/k3s
        break
      fi
      rm -f $1
    }
  done
}
xfn_dlget_airgap() {
  set -- ${1//,/ }
  while true; do
    [ ! -e $1 ] && curl -#4fSLo $1 $2
    [ -e $1 ] && {
      if [ X$3 = X$(sha256sum $1 | awk '{printf $1}') ]; then
        ##passed-checksum
        mkdir -p ${timgdir:="$pakdir/var/lib/rancher/k3s/agent/images"}
        install -m 644 $1 $timgdir/${1##*/}
        break
      fi
      rm -f $1
    }
  done
}
################################################
xfn_get_cversion() {
  ###via-github.com
  local chnfile="$cahdir/k3s_channels.yaml"
  local chn_url="${GHCDN}/https://raw.githubusercontent.com"
  while [ ! -e $chnfile ]; do
    curl -4fsSLo $chnfile $chn_url/k3s-io/k3s/refs/heads/master/channel.yaml
    sleep 1
  done #&>/dev/null
  cversion=$(awk '/^\s+latest: v.*/{printf $2}' $chnfile | sed 's,+,_,')
}
xfn_get_dldlist() {
  while [ ! -e $1 ]; do
    local api_url='https://api.github.com/repos/k3s-io/k3s/releases'
    local pat_jqx='.[].assets[].browser_download_url'
    local pat_awk="!/rc/&&/$2/&&/$3/"
    command curl -4fsSL $api_url | jq "$pat_jqx" | awk "${pat_awk}" |
      xargs -n1 | sed "s@^@${GHCDN}/@" >$1
    sleep 1
  done
}
################################################
: ${GHCDN:="https://ghfast.top"}
mt::tip_step && rm -rf /tmp/k3s_offline_install.* 2>/dev/null
local tgzout="$HOME/k3s_offline_package.bin"
local pakdir=$(mktemp -d -t k3s_offline_install.XXXXXXXX)
local cahdir=$HOME/.offline_k3s && mkdir -p $cahdir 2>/dev/null
local shfile="$cahdir/k3s_install.sh"
local hhfile="$cahdir/sha256sum-amd64.txt"
local shgurl="https://get.k3s.io"
## get-latest-stable-version ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local k3scnmir='https://rancher-mirror.rancher.cn/k3s' vnbseurl=
local cversion=$(timeout 2 curl -4fsSL $k3scnmir/channels/stable 2>/dev/null)
if [ X0Z != X${#cversion}Z ]; then
  ##via-mirror.rancher.cn
  shgurl="$k3scnmir/k3s-install.sh"
  vnbseurl=$k3scnmir/${cversion/+/-}
  cversion=${cversion/+/_}
  ##download-hashfile
  [ ! -e $hhfile ] && curl -4fsSLo $hhfile $vnbseurl/${hhfile##*/}
  ##download:binaryfile
  set -- $(awk '/k3s$/' $hhfile)
  xfn_dlget_k3sbin $cahdir/k3s_${cversion}_amd64.bin,$vnbseurl/$2,$1
  ##download:airgap.tar.gz
  set -- $(awk '/amd64/&&/tar.gz$/' $hhfile)
  xfn_dlget_airgap $cahdir/k3s_${cversion}_amd64_airgap.tgz,$vnbseurl/$2,$1
else
  ##via-github.com/k3s-io/k3s
  ################################################
  local dl_lst="$cahdir/k3s_download.list"
  xfn_get_cversion
  xfn_get_dldlist $dl_lst ${cversion//_/ }
  [ ! -e $hhfile ] && {
    awk '/sha256sum-amd64.txt$/' $dl_lst | xargs curl -4fsSLo $hhfile
  }
  ## download-verfiy-install-binaryfile
  { set -- $(awk '/k3s$/' $dl_lst $hhfile | xargs); } 2>/dev/null
  xfn_dlget_k3sbin $cahdir/k3s_${cversion}_amd64.bin,$1,$2
  ## download-verfiy-install-airgap-tar.gz
  { set -- $(awk '/amd64/&&/tar.gz$/' $dl_lst $hhfile | xargs); } 2>/dev/null
  xfn_dlget_airgap $cahdir/k3s_${cversion}_amd64_airgap.tgz,$1,$2
fi
## download:k3s_install.sh
[ ! -e $shfile ] && curl -4fsSLo $shfile $shgurl
[ -e $shfile ] && {
  mkdir -p $pakdir/opt
  install -m 755 $shfile $pakdir/opt/install.sh
}
## create-mirror-of-[docker.io]
{ K3S_MIRDIR=$pakdir/etc/rancher/k3s dfn_setmir_myk3s; } &>/dev/null
## dopack-all-together
(cd $pakdir && {
  dfn_k3s_tips 0
  tar -zcf - [a-z]*/ | base64 | sed 's@^@#DL#@'
} >$tgzout)
rm -rf $pakdir 2>/dev/null
