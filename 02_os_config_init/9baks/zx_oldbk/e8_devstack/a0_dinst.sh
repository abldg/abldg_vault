#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: a0_dinst.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================

dfn_inst_devstack() {
  ###
  xf_chk_usrstack() {
    set -- stack /opt/stack
    ##prepare-stack-user
    if [ X1 != X$(command grep -Ec "^$1:" /etc/group 2>/dev/null) ]; then
      sudo useradd -s /bin/bash -d $2 -m $1 && {
        sudo chmod +x $2
        echo "$1 ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/10_$1
        echo "${1}:${STACK_PSWD:-$1}" | sudo chpasswd --
      }
    fi
  }
  ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  xf_pst_envs() {
    DSBSE=${SHV_DS_GITBSE:-https://github.com}
    DSVER='stable/2025.1'
    MCDIR=${MYCACHE:-${HOME}/.cache/osci}
    mkdir -p ${MCDIR} 2>/dev/null
    [ $(id -u)X = 0X ] && S= || S='sudo '
  }
  ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  xf_pst_pipconf() {
    set -- /opt/stack/.pip mbk/smpfile_pip_conf
    [ -e $2 ] && {
      mkdir -p $1 2>/dev/null
      cp $2 $1/pip.conf
    }
  }
  ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  xf_cln_repos() {
    mycln() {
      set -- /opt/stack/$1 ${DSBSE}/openstack/$1.git $2
      [ ! -d $1 ] && git clone --depth=1 -b ${3:-${DSVER}} $2 $1
    }
    set -- cinder glance horizon keystone neutron nova swift placement
    local x=
    for x in $@; do mycln $x ${DSVER}; done
    set -- requirements neutron-tempest-plugin
    for x in $@; do mycln $x master; done
  }
  ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  xf_pst_devstack() {
    _pdl_files() {
      x_dlf() {
        set -- files/$1 ${MCDIR}/$1 https://$2/$1
        [ ! -e $2 ] && command curl -#4fSLo $2 $3
        [ -e $2 ] && [ ! -e $1 ] && {
          cp $2 $1
          [ X1 = X$FLG_DOWNLOAD ] && touch $1.downloaded
        }
      }
      # [ ! -d files ] && mkdir files
      FLG_DOWNLOAD=1 x_dlf get-pip.py bootstrap.pypa.io
      x_dlf etcd-v3.4.37-linux-amd64.tar.gz \
        ghfast.top/https://github.com/etcd-io/etcd/releases/download/v3.4.37
      x_dlf cirros-0.6.3-x86_64-disk.img \
        ghfast.top/https://github.com/cirros-dev/cirros/releases/download/0.6.3
      #x_dlf jammy-server-cloudimg-amd64.img \
      #  mirrors.tuna.tsinghua.edu.cn/ubuntu-cloud-images/jammy/20250430
    }
    ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    local dstd=/opt/stack/1-devstack
    [ -d $dstd ] || {
      git clone -4 --depth=1 -b ${DSVER} \
        ${DSBSE}/openstack/devstack.git ${dstd}
    }
    ##
    local cpfx='smpfile' cifn="${SHV_SSH_IFN:-eno1}"
    [ XctlZ != X${SHV_DSN_ROLE}Z ] && cpfx='smpfile_none'
    set -- mbk/${cpfx}_control_local_conf
    [ -e $1 ] && {
      local jfx='.[0].addr_info[0].local'
      local myip=$(ip -4 -j addr show ${cifn} | jq "${jfx}" | xargs)
      cat $1 | sed "s|RV_MYLOCALIP.*$|${myip}|"
      # local ip4='IP_VERSION=4'
      # echo -e "##\n${ip4}\nTUNNEL_${ip4}\nSERVICE_${ip4}"
    } >${dstd}/local.conf
    ##
    (
      cd ${dstd} && sed -i 's,egrep,command grep -E,' \
        functions* tests/test_functions.sh
      (_pdl_files)
    )
  }
  ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  xfn_getlocateinfo && cd $LOCDIR
  mt::tip_step
  xf_chk_usrstack
  xf_pst_envs
  xf_pst_pipconf
  xf_cln_repos
  xf_pst_devstack
}
