#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: sht_reinit_disk_ge_1T.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================
# set -x
pthdev=$(lsblk -r -o NAME,TYPE,SIZE | awk '/disk/&&/.[0-9]T$/{print $1}')
if [ ${#pthdev} -ge 1 ]; then
  if [ X2 != X$(command grep -nc $pthdev /proc/partitions) ]; then
    pthfll=/dev/$pthdev && wipefs --force --all $pthfll &&
      echo -e 'o\ng\ng\nn\n\n\n\n\nw\n' | fdisk $pthfll
  fi
  pthpart=/dev/$(lsblk -r -o NAME,TYPE | awk '/^'$pthdev'/&&/part$/{printf $1}')
  if [ -e $pthpart ]; then
    ffs=/etc/fstab
    out="$(blkid $pthpart | xargs)"
    #1#
    if [ X1 != X$(echo "$out" | command grep -nc 'TYPE=ext4') ]; then
      mkfs.ext4 $pthpart && sleep 5
    fi
    #2#
    idp=$(echo $out | xargs -n1 | awk -F'=' '/^UUID=/{print $2}')
    if [ ${#idp} -ge 1 ] && [ X1 != X$(command grep -nc "/$idp" $ffs) ]; then
      printf '/dev/disk/by-uuid/%s\t/opt ext4 defaults 0 1\n' $idp >>$ffs
    fi
    #3#
    swp='/swap.img'
    sed -i -r '/^.swap.img/s@^@# @' $ffs
    [ -e $swp ] && swapoff $swp && rm -f $swp
  fi
fi
# set +x
