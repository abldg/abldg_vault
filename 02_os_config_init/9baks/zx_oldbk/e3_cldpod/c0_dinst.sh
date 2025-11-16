#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: c0_dinst.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================
dfn_cldpod_tips() {
  # { [ -e ${OSFLE:='/etc/os-release'} ] && . ${OSFLE}; } 2>/dev/null
  xfn_get_ocboot() {
    rm -rf $1 2>/dev/null
    mkdir -p $1
    local xopts='--strip-components=1 --no-same-owner --no-same-permissions'
    local ubase='https://ghfast.top/https://github.com/yunionio/ocboot'
    local aurl='https://api.github.com/repos/yunionio/ocboot/releases'
    local rels=$(curl -4sSL $aurl | jq -r '.[].tag_name' | head -n 1)
    curl -4sfSL $ubase/archive/refs/tags/${rels}.tar.gz |
      tar -C $1 $xopts -zxf - && (
      cd $1 && git init && git add . && git commit -m 'reinit'
    ) &>/dev/null
  }
  ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~@@
  # local ocbtdir=$HOME/zx_ocboot
  mt::locate_defs && local ocbtdir=${LOCDIR:-$HOME}/zx_ocboot
  return
  xfn_get_ocboot $ocbtdir
  [ XZ = X$(command -v buildah)Z ] && $P_INSTALL buildah
  # 禁用selinux，否则安装配置文件 config-allinone-current.yml 会写入失败
  local k=setenforce && hash $k &>/dev/null && $k 0
  ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if [ -d $ocbtdir ]; then
    local ip4=$(ip -4 -j addr | jq '.[1].addr_info[0].local' | xargs)
    local cnk3s_fsh='https://rancher-mirror.rancher.cn/k3s/k3s-install.sh'
    # cp $LOCDIR/ocboot.sh $ocbtdir/
    curl -4fsSLo $ocbtdir/airgap_assets/k3s-install.sh $cnk3s_fsh
    echo "cd $ocbtdir && bash -x ./ocboot.sh run.py virt $ip4"
  fi
}
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
dfn_cldpod_inst_online() {
  mt::tip_step && mt::locate_defs
  local ocbtver=release/${OCBT_REL_VER:-3.11} ocbtdir=$HOME/zx_ocboot
  [ X1 = X${OCBT_LOC_ENB:-0} ] && ocbtdir=$LOCDIR/zx_ocboot
  set -- "ver=$ocbtver#dst=$ocbtdir#cgr=$LOCDIR/sht_setup_ha.sh"
  $MYBASH $SHV_DIR_INST/*_inst_cldpod_ljjx.sh $1
}
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
