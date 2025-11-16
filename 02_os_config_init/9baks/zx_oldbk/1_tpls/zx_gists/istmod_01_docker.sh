#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: istmod_01_docker.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================

# rtf0h2092ed1um.xuanyuan.run
{ . /etc/os-release; } 2>/dev/null
CNTIDX=1
_info() {
  { echo -e "[<\e[32;1mINFO-$((CNTIDX++))\e[0m>] \e[33m$*\e[0m"; } 2>/dev/null
}
_warn() {
  { echo -e "[<\e[33;1mWARN-$((CNTIDX++))\e[0m>] \e[31m$*\e[0m"; } 2>/dev/null
}
##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
_info "开始[ubuntu20.04+]安装[docker]的步骤"
############################################
mkdir -p /etc/docker 2>/dev/null
bash -c 'cat >/etc/docker/daemon.json<<"EEE"
{
  "insecure-registries": ["rtf0h2092ed1um.xuanyuan.run"],
  "registry-mirrors": ["https://rtf0h2092ed1um.xuanyuan.run"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "storage-driver": "overlay2",
  "max-concurrent-downloads": 100,
  "log-driver": "json-file",
  "log-level": "info",
  "log-opts": { "max-size": "50m", "max-file": "3" },
  "features": { "buildkit": true }
}
EEE' && _info "生成[/etc/docker/daemon.json]"
############################################
install -m 0755 -d /etc/apt/keyrings /etc/apt/sources.list.d 2>/dev/null
aptmirurl="https://mirrors.aliyun.com/docker-ce/linux/ubuntu"
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ascdocker="/etc/apt/keyrings/docker.asc"
curl -fsSLo $ascdocker $aptmirurl/gpg && chmod a+r $ascdocker
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
aptdocker="/etc/apt/sources.list.d/docker.sources"
fmt+="\nTypes: deb"
fmt+="\nURIs: $aptmirurl"
fmt+="\nSuites: $UBUNTU_CODENAME"
fmt+="\nComponents: stable"
fmt+="\nSigned-by: $ascdocker"
printf "###ADD_BY_LDG\n${fmt}\n" >$aptdocker && _info "生成[$aptdocker]"
############################################
pkgs=(
  containerd.io docker-ce docker-ce-cli
  docker-compose-plugin docker-buildx-plugin
  # docker-model-plugin docker-ce-rootless-extras
  ca-certificates
)
apt-get update && apt-get -y install ${pkgs[@]}
############################################
if [ X != X$(command -v docker) ]; then
  systemctl daemon-reload
  systemctl restart docker
  docker info
fi
