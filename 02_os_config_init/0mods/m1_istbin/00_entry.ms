#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: 01_entry.sf
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 16:23:19
## VERS: 1.0.1
##==================================----------==================================
mt::load_funcs() {
  local thzmod_fullpath=${BASH_SOURCE%/*} newfile=
  for newfile in ${thzmod_fullpath}/scripts/*_*.sh; do . $newfile; done
}
# : "#{{{{ BGN-ENTRY: $BASH_SOURCE"
mt::load_funcs
unset -f mt::load_funcs
# : "#}}}} END-ENTRY: $BASH_SOURCE"
###!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!###
priv::cmfunc::upt_docker_daemon_json() {
  local tpl='{
  #DP#R4S#"bridge": "none",
  #DP#R4S#"exec-opts": [
  #DP#R4S#R4S#"native.cgroupdriver=systemd"
  #DP#R4S#],
  #DP#R4S#"features": {
  #DP#R4S#R4S#"buildkit": true
  #DP#R4S#},
  #DP#R4S#"insecure-registries": ['$glb_opt'],
  #DP#R4S#"log-driver": "json-file",
  #DP#R4S#"log-level": "info",
  #DP#R4S#"log-opts": {
  #DP#R4S#R4S#"max-file": "3",
  #DP#R4S#R4S#"max-size": "50m"
  #DP#R4S#},
  #DP#R4S#"max-concurrent-downloads": 100,
  #DP#R4S#"registry-mirrors": [
  #DP#R4S#R4S#"https://'${glb_cdn:-docker.1ms.run}'"
  #DP#R4S#],
  #DP#R4S#"storage-driver": "overlay2"
  #DP#}'
  set -- /etc/docker && mkdir -p $1 2>/dev/null
  set -- $1/daemon.json && echo "${tpl}" 2>/dev/null |
    sed -r 's@\s+?#DP#@@g;s@R4S#@    @g' >$1
}
priv::cmfunc::upt_aptlist::ubuntu() {
  : 'use-tsinghua-mirror'
  local tzarch=${1:-"amd64"} && { . /etc/lsb-release; } 2>/dev/null
  set -- /etc/apt/sources.list.d && mkdir -p $1 2>/dev/null
  set -- ${1}/ubuntu.sources ${DISTRIB_CODENAME:-"noble"}
  {
    echo "##LJJX_ADD: $(date +%s)##"
    echo "Types: deb"
    echo "URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu"
    echo "Suites: $2 $2-updates $2-backports $2-security"
    echo "Components: main restricted universe multiverse"
    echo "Architectures: ${tzarch}"
    echo "Signed-by: /usr/share/keyrings/ubuntu-archive-keyring.gpg"
  } 2>/dev/null | tee $1
}
priv::cmfunc::upt_aptlist::docker() {
  : 'use-aliyun-mirror'
  local mirurl="https://mirrors.aliyun.com/docker-ce/linux/ubuntu"
  local tzarch=${1:-"amd64"} && { . /etc/lsb-release; } 2>/dev/null
  set -- /etc/apt/sources.list.d && mkdir -p ${1} 2>/dev/null
  set -- ${1}/docker.sources /usr/share/keyrings/docker.asc && {
    echo "##LJJX_ADD: $(date +%s)##"
    echo "Types: deb"
    echo "URIs: ${mirurl}"
    echo "Suites: ${DISTRIB_CODENAME:-noble}"
    echo "Components: stable"
    echo "Architectures: ${tzarch}"
    echo "Signed-by: ${2}"
  } 2>/dev/null | tee ${1} && curl -fsSLo ${2} ${mirurl}/gpg
}
priv::cmfunc::upt_aptlist::libnvidiacontainer() {
  : 'use-ustc-mirror'
  local lnc="libnvidia-container"
  set -- https://nvidia.github.io/$lnc/gpgkey /usr/share/keyrings/$lnc.gpg
  rm -f $2 2>/dev/null
  (curl -f4sSL $1 | gpg --dearmor -o $2) &&
    set -- $2 https://mirrors.ustc.edu.cn/$lnc && {
    echo "deb [signed-by=$1] $2/stable/deb/amd64 /"
    echo "#deb [signed-by=$1] $2/experimental/deb/amd64 /"
  } | tee /etc/apt/sources.list.d/$lnc.list
}
