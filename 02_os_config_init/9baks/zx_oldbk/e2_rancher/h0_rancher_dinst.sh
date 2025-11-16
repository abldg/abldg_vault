#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: k0_dinst.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
dfn_upt_registry_mirror() {
  mt::locate_defs
  fsrc=$LOCDIR/registries.yaml
  if [ -e $fsrc ]; then
    ydir=/etc/rancher/k3s && mkdir -p $ydir 2>/dev/null
    cp $fsrc $ydir/
  fi
}
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
dfn_install_k3s_online() {
  # CNMIR="https://rancher-mirror.rancher.cn"
  # CHFLE=$HOME/.cache/osci/linux_k3s_install.sh
  # mkdir -p ${CHFLE%/*} 2>/dev/null
  # ##获取k3s-install.sh
  # [ ! -e $CHFLE ] && {
  #   curl -#4fSLo $CHFLE $CNMIR/k3s/k3s-install.sh
  #   chmod a+x $CHFLE
  # }
  # [ -e $CHFLE ] && {
  #   ##
  #   [ X = X$(command -v iptables) ] && apt install -y iptables
  #   ##
  #   dfn_upt_registry_mirror
  #   ##
  #   instopts=(
  #     INSTALL_K3S_MIRROR=cn
  #     INSTALL_K3S_BIN_DIR=${INSTALL_K3S_BIN_DIR:-}
  #     INSTALL_K3S_VERSION=${INSTALL_K3S_VERSION:-v1.32.4+k3s1}
  #     INSTALL_K3S_MIRROR_URL=${INSTALL_K3S_MIRROR_URL:-$CNMIR}
  #     INSTALL_K3S_SYSTEMD_DIR=${INSTALL_K3S_SYSTEMD_DIR:-/etc/systemd/system}
  #   )
  #   export ${instopts[@]}
  #   $SUDO bash $CHFLE
  # }
  dfn_upt_registry_mirror
  ##
  curl -sfL https://get.k3s.io |
    sed 's@github.com@ghfast.top/https://github.com@' |
    INSTALL_K3S_VERSION=${INSTALL_K3S_VERSION:-v1.32.4+k3s1} \
      bash -s - server --cluster-init
  if [ -x ${bin_k3s:=/usr/local/bin/k3s} ]; then
    $bin_k3s -v #version
    kubectl version
    crictl version
  fi
}
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
dfn_kubectl_install_cert_manager() {
  [ X = X$(command -v kubectl) ] && dfn_install_k3s_online
  set -- cert-manager
  CMYAML=https://github.com/$1/$1/releases/download/v1.18.2/$1.yaml
  kubectl apply -f https://ghfast.top/$CMYAML
}
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
dfn_helm_install_rancher() {
  dfn_kubectl_install_cert_manager
  chnnel=stable
  reponame=rancher-$chnnel
  repo_url=https://rancher-mirror.rancher.cn/server-charts/$chnnel
  helm repo add $reponame $repo_url
  kubectl create namespace cattle-system

  helm install rancher $reponame/rancher \
    --namespace cattle-system \
    --set replicas=1 \
    --set hostname=192.168.100.2.nip.io \
    --set bootstrapPassword=ljjx-rancher \
    --set rancherImage=registry.cn-hangzhou.aliyuncs.com/rancher/rancher \
    --set systemDefaultRegistry=registry.cn-hangzhou.aliyuncs.com
}
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
