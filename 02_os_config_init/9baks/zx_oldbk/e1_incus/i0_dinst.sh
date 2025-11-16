#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: i0_dinst.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================
dfn_incus_inst() {
  _do_os_check() {
    if [[ $VERSION_CODENAME != @(noble|jammy|focal|bullseye|bookworm) ]]; then
      _red "[FATAL] only support ubuntu20.04+ or debian 11/12"
    fi
    if [[ X0 != X$(id -u) ]]; then
      _red "[FATAL] only support root run this tools"
    fi
    if [[ $(systemd-detect-virt) != @(none|kvm|vmware) ]]; then
      _red "[FATAL] incus need kvm-based-virt-server or a bare-metal-server"
    fi
  }
  _try_inst_incus() {
    set -- /etc/apt/sources.list.d /usr/share/keyrings/zabbly.asc
    #[1]-copy-asc-file
    cp $LOCDIR/*_zabbly.asc $2
    #[2]
    mkdir -p $1 2>/dev/null
    {
      echo 'Types: deb'
      echo 'URIs: https://mirrors.ustc.edu.cn/incus/stable'
      echo 'Suites: '$VERSION_CODENAME
      echo 'Components: main'
      echo 'Signed-By: /usr/share/keyrings/zabbly.asc'
    } >$1/incus.sources
    #[3]
    apt update -y && apt install -y incus-base incus-client incus-ui-canonical
    systemctl enable incus --now
  }
  _do_incus_cfg_init() {
    ###
    mirurl=https://mirrors.nju.edu.cn/lxc-images/
    incus remote remove images
    incus remote add images $mirurl --protocol=simplestreams --public
    ###
    incus config trust add-certificate $LOCDIR/*incus_ui*.crt
    ###
    local ivs=(
      limits.cpu,8
      limits.memory,8GiB
      boot.autostart,true
      security.guestapi,true
      security.nesting,true
      security.privileged,true
      security.secureboot,false
    )
    for x in ${ivs[@]}; do incus profile set default ${x//,/ }; done
  }
  ##
  { [ -e ${OSFLE:='/etc/os-release'} ] && . ${OSFLE}; } 2>/dev/null
  mt::tip_step && _do_os_check && mt::locate_defs && _try_inst_incus
  [ X != X$(command -v incus) ] && _do_incus_cfg_init
  ##############################
  # if [ X != X$(command -v incus) ] && [ X1 = X${SHV_INCUS_DIT:-0} ]; then
  #   _xf_upt_diskdev() {
  #     local zfsdev=$(ls -1 /dev/sd* | sed 's,[0-9],,' | sort | uniq -c |
  #       xargs -n2 | awk '/^1 /{print $2}' | head -1)
  #     if [ X0 = X${#zfsdev} ]; then
  #       set -- ${SHV_INCUS_DRT:-/opt/incusrt} && mkdir -p $1
  #       _yellow "[WARN] zfsdev is empty, create dir-source [$1] !!!"
  #       incus storage create disks dir source=${1}
  #       incus profile device add default root disk path=/ pool=disks size=20GiB
  #     else
  #       mt::ispkgexist zfsutils-linux,zfs
  #       # mt::ispkgexist qemu-system,qemu-img
  #       # mt::ispkgexist ubuntu-drivers-common,ubuntu-drivers
  #       {
  #         wipefs --all --force ${zfsdev}
  #         echo -e 'g\ng\ng\ng\nw\n' | fdisk ${zfsdev}
  #       } &>/dev/null
  #       incus storage create disks zfs source=${zfsdev}
  #       incus profile device add default root disk path=/ pool=disks size=10GiB
  #     fi
  #   }
  #   ###
  #   {
  #     echo "no,no,no,yes,${SHV_INCUS_IFN:-br0},yes,all,8443,yes,no,," |
  #       sed 's@,@\n@g' | incus admin init
  #   } &>/dev/null
  # fi
}
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
dfn_incus_tips() {
  set +x
  mt::locate_defs # && bash ${LOCDIR}/*_${FUNCNAME#dfn_}*
  (
    cd $LOCDIR
    #[1]~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    local sfx='###############################'
    echo "$sfx admin-init-modes $sfx"
    echo -e '#[TIP]. [\e[33;41;1mCLUSTER\e[0m]-mode'
    { source <(cat *_incus_admin_init*.tgb); } 2>/dev/null
    { echo "$iai_for_cluster"; } 2>/dev/null | base64 -d | tar -Ozxf - && echo
    #[2]~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    local crtfile=$(ls $PWD/*incus_ui.crt)
    cat *_other_${FUNCNAME#dfn_}*.sh | sed \
      -e "s@RV_UICRT@${crtfile}@"
  )
}
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
