#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: 01_entry.sf
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 16:23:19
## VERS: 1.0.1
##==================================----------==================================
# mt::load_funcs() {
#   local thzmod_fullpath=${BASH_SOURCE%/*} newfile=
#   for newfile in ${thzmod_fullpath}/scriptsx/*_*.sh; do . $newfile; done
# }
# # : "#{{{{ BGN-ENTRY: $BASH_SOURCE"
# mt::load_funcs
# unset -f mt::load_funcs
# # : "#}}}} END-ENTRY: $BASH_SOURCE"

##!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!##

shfn::ubuntu::allinit() {
  local steps=
  steps+=(
    fix::wait120s_ifn_online
    update::apt_source_list
    disable::svc_timers
    fix::ubt2204_netplan_apply_warn
    # enable::vfio_pci
  )
  [ X != X$(command -v netplan) ] && steps+=(update::ntplyml)
  eval "$(printf 'shfn::ubuntu::%s;' ${steps[@]})"
}
##----------------------------------------------------------------------------##
shfn::ubuntu::update::apt_source_list() {
  ##call istbin/apt_basic
  priv::cmfunc::upt_aptlist::ubuntu
  priv::cmfunc::upt_aptlist::docker
  priv::cmfunc::upt_aptlist::libnvidiacontainer
}
##----------------------------------------------------------------------------##
shfn::ubuntu::fix::wait120s_ifn_online() {
  set -- /etc/systemd/system/network-online.target.wants
  [ -d $1 ] || return
  ##remove-old-configs
  sed -r -i '/^TimeoutStartSec=/d' $1/*.service
  ##add-new-config
  sed -r -i '/^RemainAfterExit=yes/aTimeoutStartSec=2' $1/*.service
}
##----------------------------------------------------------------------------##
shfn::ubuntu::fix::ubt2204_netplan_apply_warn() {
  [ $(command grep -c '=jammy' /etc/os-release) -lt 2 ] && return
  set -- /usr/share/netplan/netplan/cli/commands/apply.py
  [ ! -e $1 ] && return
  ##delete-last-lines
  sed -r -i '/^\s+except OvsDbServerNotRunning as e:$/,${d}' $1
  {
    echo "4S#4S#except OvsDbServerNotRunning as e:"
    echo "4S#4S#4S#if utils.systemctl_is_active('ovsdb-server.service'):"
    echo "4S#4S#4S#4S#logging.warning('Cannot call Open vSwitch: {}.'.format(e))"
  } 2>/dev/null | sed 's@4S#@    @g' | tee -a $1
}
##----------------------------------------------------------------------------##
shfn::ubuntu::disable::svc_timers() {
  ## 设置为多用户模式启动
  systemctl set-default multi-user.target

  ## 禁用 CTRL-ALT-DEL 重启的快捷键
  systemctl mask ctrl-alt-del.target

  ## 禁用 定时器
  local TIMERSDIR="/etc/systemd/system/timers.target.wants"
  if [ -d $TIMERSDIR ]; then
    (
      cd $TIMERSDIR
      rm -f apt-daily* apport-autoreport.timer motd-news.timer
      rm -f update-notifier-* ua-timer.timer fwupd-refresh.timer
    )
  fi
  ## 禁用 多余的服务
  local MUSRDIR="/etc/systemd/system/multi-user.target.wants"
  if [ -d $MUSRDIR ]; then
    (
      cd $MUSRDIR
      rm -f apport.service lxd-installer.socket ufw.service
      rm -f ua-reboot-cmds.service unattended-upgrades.service
      rm -f ModemManager.service rsyslog.service secureboot-db.service
    )
  fi
  ## 移除软件包[cloud-init, snapd及needrestart]
  local CLOUDIR="/etc/cloud"
  if [ -d $CLOUDIR ]; then
    rm -rf $CLOUDIR
    apt purge --auto-remove -y cloud-init snapd needrestart
  fi
}
##----------------------------------------------------------------------------##
shfn::ubuntu::enable::vfio_pci() {
  ## 获取所有的NVIDIA相关的设备列表
  local nvlst=($(lspci -nk | awk '/10de:(2206|1e04)/{print $3}' | sort -u))

  ## 更新配置
  set -- /etc/modprobe.d && mkdir -p $1
  [ ${#nvlst[@]} -ge 1 ] && {
    echo '##ADD-BY-LJJX'
    echo '##append-into-blocklist'
    echo 'blacklist amd76x_edac'
    echo 'blacklist nouveau'
    echo 'blacklist nvidia'
    echo 'blacklist nvidiafb'
    echo 'blacklist rivafb'
    echo 'blacklist rivatv'
    echo 'blacklist snd_hda_intel'
    echo 'blacklist vga16fb'
    echo ''
    echo '##newadd-vfio'
    echo 'options vfio-pci ids='"${nvlst[@]}"
  } >$1/ljjx-nvidia-devices-use-vfio-pci.conf
  ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## 更新配置
  set -- /etc/modules-load.d && mkdir -p $1
  {
    echo '##ADD-BY-LJJX'
    echo 'kvm'
    echo 'kvm_intel'
    echo 'pci_stub'
    echo 'vfio'
    echo 'vfio_iommu_type1'
    echo 'vfio_pci'
  } >$1/ljjx-autoload-vfio-kvm-drivers.conf
  ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ##更新grub
  local cfg="/etc/default/grub"
  local kwd="GRUB_CMDLINE_LINUX_DEFAULT"
  [ ! -e $cfg ] && return
  if [ X0 = X$(grep -Ec '^'$kwd'=".*iommu=pt' $cfg) ]; then
    set -- intel_iommu=on amd_iommu=on iommu=pt \
      default_hugepagesz=1G hugepagesz=1G hugepages=8
    # sed -r -i "s|^($kwd)=\"([^\"]+)\"$|\1=\"\2 $*\"|" $cfg && update-grub2
    eval "sed -r -i 's|^(${kwd}=\"[^\"]+)\"$|\1 ${*}\"|' $cfg" && update-grub2
  fi
  ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
}
##----------------------------------------------------------------------------##
shfn::ubuntu::update::ntplyml() {
  ## 更新[/etc/systemd/resolved.conf]
  bash -c 'sed -r -i -e "/^#?DNS=/s@.*@DNS=114.114.114.114@" \
  -e "/^#?FallbackDNS=/s@.*@FallbackDNS=223.5.5.5@" \
  /etc/systemd/resolved.conf; rm -f /etc/resolv.conf;
  printf "nameserver %s\n" 114.114.114.114 223.5.5.5 >/etc/resolv.conf'

  ## 禁用 127.0.1.1 映射
  sed -r -i '/^127.0.1.1/s@^@#@' /etc/hosts

  [ X = X$(command -v netplan) ] && return
  set -- $(ip link | awk -F': ' '$2~/^e[ntm].*/{print $2}')
  local ifn1=$1 ifn2=$2
  [ X${#ifn1} = X0 ] && ifn1=eno1
  [ X${#ifn2} = X0 ] && ifn2='#ifnX'

  ## 获取eno1口的IP及网关
  local ip_1=$(ip -4 addr show dev $ifn1 | awk '/inet /{printf $2}')
  local gw_1=$(ip -4 -j r get 1 | jq -r '.[0]|select(.gateway!=null)|.gateway')
  [ X${#ip_1} = X0 ] && ip_1='192.168.100.2/24'
  [ X${#gw_1} = X0 ] && gw_1='192.168.100.1'

  ## 删除旧配置
  rm -f /etc/netplan/*.yaml 2>/dev/null
  set -- /etc/netplan/00_loclan.yaml
  ## 保存新配置
  {
    local tpl_new_ntplyml='
    #TDL#network:
    #TDL#  version: 2
    #TDL#  ethernets:
    #TDL#    RV_IFN2: { dhcp4: no, link-local: [] }
    #TDL#    RV_IFN1:
    #TDL#      dhcp4: no
    #TDL#      dhcp6: no
    #TDL#      addresses:
    #TDL#      - RV_IP1
    #TDL#      routes:
    #TDL#      - { metric: 100, to: 0.0.0.0/0, via: RV_GW1 }
    #TDL#      nameservers:
    #TDL#        addresses: [ 223.5.5.5, 114.114.114.114, 8.8.8.8 ]
    '
  } 2>/dev/null
  { echo "$tpl_new_ntplyml"; } 2>/dev/null | sed -r \
    -e 's|\s+#TDL#||' \
    -e "s|RV_IFN2|$ifn2|" \
    -e "s|RV_IFN1|$ifn1|" \
    -e "s|RV_IP1|$ip_1|" \
    -e "s|RV_GW1|$gw_1|" | tee $1 && chmod 600 $1

  ## 使配置生效
  netplan apply
}
