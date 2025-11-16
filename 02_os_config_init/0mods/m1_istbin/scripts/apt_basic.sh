#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: apt_basic.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================
shfn::istbin::apt_basic() {
  priv::cmfunc::upt_aptlist::ubuntu
  ## 更新列表+升级到最新+安装常用的软件包
  set -- curl gawk git make # gcc jq libffi-dev libssl-dev libdbus-glib-1-dev
  apt update -y && apt upgrade -y && apt install -y $@

  local tlst=(
    bzip2 curl dos2unix file fping
    git ipcalc make screen sshfs
    sudo tig tmux tree unzip
    wget zip gawk
    lrzsz,rz
    xz-utils,xz
    chrony,chronyc
    pciutils,lspci
    usbutils,lsusb
    uidmap,newuidmap
    net-tools,netstat
    bridge-utils,brctl
    openssh-server,sshd
    bash-completion,compgen
  )
  if [ "X${ID}Y${NAME}Z" = "XubuntuYUbuntuZ" ]; then
    tlst+=(lsb_release isc-dhcp-client,dhclient
      software-properties-common,add-apt-repository)
  fi
  cout() {
    case $1 in
    "") tput sgr0 ;;
    [1-9]) tput setaf $1 ;;
    esac
  }

  mt::tip_step && apt-get update &>/dev/null && set +x
  local vs= && for x in ${tlst[@]}; do
    set -- ${x//,/ }
    vs=$(command -v ${2:-${1}} 2>/dev/null)
    if [ X0 = X${#vs} ]; then
      printf "@===> $(cout 6)try to install: $(cout 3)$1$(cout)\n"
      apt-get install -y $1
      hash -r && vs=$(command -v ${2:-${1}} 2>/dev/null)
    fi
    [ X0 != X${#vs} ] && printf "@===> $(cout 2)installed: $(cout 4)$1$(cout)\n"
  done
}

shfn::istbin::apt_libnvidia_container() {
  priv::cmfunc::upt_aptlist::libnvidiacontainer
  ###!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!###
  set -- ${NVIDIA_CONTAINER_TOOLKIT_VERSION:=1.18.0-1}
  local pkgs=(
    libnvidia-container1=${1}
    libnvidia-container-tools=${1}
    nvidia-container-toolkit=${1}
    nvidia-container-toolkit-base=${1}
  )
  apt-get install -y ${pkgs[@]} && nvidia-ctk runtime configure --runtime=docker

  # 服务重启
  sudo systemctl daemon-reload && systemctl restart containerd docker

  # 验证运行时
  docker info | grep "Runtimes"
  # Runtimes: io.containerd.runc.v2 nvidia runc
}

shfn::istbin::apt_dkdkc() {
  priv::cmfunc::upt_aptlist::docker
  priv::cmfunc::upt_docker_daemon_json
  ###!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!###
  if [ X != X$(command -v docker) ]; then
    if [ X0 = X${SHV_FORCE:-0} ]; then
      docker version
      docker compose version
      return
    fi
  fi
  ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###
  local pkgs=(
    containerd.io
    docker-ce
    docker-ce-cli
    docker-compose-plugin
    docker-buildx-plugin
    # docker-model-plugin
    # docker-ce-rootless-extras
    ca-certificates
  )
  apt update && apt-get -y install ${pkgs[@]}
  ###//////////////////////////////////////////////////////////////////////###
  systemctl daemon-reload
  systemctl restart docker
  ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###
  docker compose version
  ###!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!###
  shfn::istbin::apt_libnvidia_container
}
