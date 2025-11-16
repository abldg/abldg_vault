#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: 21_update_sth.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================
sfu.tiny_path() {
  export PATH=$(echo "${MI_EXTRA_PATH} ${PATH//:/ }" | xargs -n1 |
    awk '!/games/' | awk '!a[$0]++' | xargs | sed 's, ,:,g')
}
#-------------------------------------------------------------------------------
# sfu.clr_knownhosts() {
#   >~/.ssh/known_hosts
#   rm -f ~/.ssh/known_hosts.old 2>/dev/null
# }
#-------------------------------------------------------------------------------
sfu.etcprofile() {
  local f=0
  [ $f -eq 0 ] && [ X1 = X$(pidof docker-init 2>/dev/null) ] && f=1
  [ $f -eq 0 ] && [ X0 != X$(env | awk '/^VSCODE_/' | wc -l) ] && f=1
  [ $f -eq 1 ] && { . /etc/profile; } >/dev/null
}
#-------------------------------------------------------------------------------
sfu.load_plnxenv() {
  local kf=$(ls -d /home/ldg/.swbase/plnx* 2>/dev/null)
  [ -e $kf/settings.sh ] && {
    . $kf/settings.sh $kf
  }
}
#-------------------------------------------------------------------------------
sfu.fix_maxwatchers() {
  sudo sed -i '/max_user_watches=/d' /etc/sysctl.conf
  echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
  sudo sysctl -p
}
#-------------------------------------------------------------------------------
tsize.sh() {
  local orgbak=$(stty -g)
  {
    stty cbreak -echo min 0 time 8
    printf '\033[18t' >/dev/tty
    IFS='[;t' read _ ch2 rn cn </dev/tty
  } &>/dev/null
  stty "$orgbak"
  if [ "$ch2" == "8" ]; then
    # local rn=${1-50} cn=${2-180}
    echo "[TIP] set terminal size: $rn x $cn"
    stty rows $rn cols $cn
  fi
}
#-------------------------------------------------------------------------------
sfu.drop_caches() {
  case $1 in
  1 | 2) echo $1 ;;
  *) echo 3 ;;
  esac | sudo tee /proc/sys/vm/drop_caches
}
#-------------------------------------------------------------------------------
sfu.change.tz2cst8() {
  timedatectl set-timezone Asia/Shanghai
}
#-------------------------------------------------------------------------------
sfu.change.locale() {
  local x=
  case $1 in
  1 | ch | zh | zh_CN) x=zh_CN.UTF-8 ;;
  *) x=en_US.UTF-8 ;;
  esac
  if [ X = X$(localectl list-locales | awk '/^'${x}'$/') ]; then
    [ -x /usr/sbin/locale-gen ] || apt install -y locales
    locale-gen $x
  fi
  set -- /etc/profile.d && mkdir -p $1 2>/dev/null
  set -- $1/88-ljjx-locale.sh
  printf 'export %s='${x}'\n' LANG LC_ALL | tee $1
  source $1
}
#-------------------------------------------------------------------------------
