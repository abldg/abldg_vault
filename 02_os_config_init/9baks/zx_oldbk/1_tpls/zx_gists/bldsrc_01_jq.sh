#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: bldsrc_01_jq.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================
dfn_bldsrc_jq() {
  do_source_build() {
    echo -e "#!/bin/sh\necho ${vern#jq-}\n" >scripts/version && autoreconf -i &&
      ./configure --host=$tpfx --with-oniguruma=builtin \
        --enable-static --enable-all-static --disable-docs \
        CFLAGS="-O2 -pthread -fstack-protector-all" LDFLAGS="-s" &&
      make -j"$(nproc)" && file ./jq &&
      if [ X$(arch) = X${tpfx%%-*} ]; then
        install -m 755 jq /usr/local/bin/
      fi
  }
  dldsrc_and_extract2wdir() {
    declare -r $@
    hsh='2be64e7129cecb11d5906290eba10af694fb9e3e7f9fc208a311dc33ca837eb0'
    url=https://github.com/jqlang/jq/releases/download/$vern/$vern.tar.gz
    chf="$CHDIR/$vern.tar.gz" && mkdir -p ${CHDIR} 2>/dev/null
    while true; do
      [ ! -e $chf ] && curl -4sfSLo $chf $GHCDN/$url
      if [ -e $chf ]; then
        if [ X${hsh}Z = X$(sha256sum $chf |awk '{printf $1}')Z ]; then
          tar --strip-components=1 --no-same-owner -zxf $chf -C $wdir
          break
        fi
        rm -f $chf
      fi
    done
  }
  check_depends() {
    declare -r $@
    ##prep-build-envs
    [ -e ${flgdone}_${tpfx} ] && return
    touch ${flgdone}_${tpfx}
    local ptilst=(gawk automake autoconf libtool pkg-config build-essential)
    case $(arch) in
    aarch64) ptilst+=(libelf-dev libmnl-dev) ;;
    x86_64) {
      if [[ ${bldtype}Z = @(1|arm64|aarch64)Z ]]; then
        tpfx=aarch64-linux-gnu
        ptilst+=(crossbuild-essential-arm64)
      fi
    } ;;
    esac
    [ XrootZ != "X${USER}Z" ] && SUDO=sudo
    $SUDO apt update -y && $SUDO apt install -y ${ptilst[@]}
  }
  #####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  tpfx=$(arch)-linux-gnu
  fkey=${FUNCNAME#dfn_} && rm -rf /tmp/$fkey.* 2>/dev/null
  wdir=$(mktemp -d -t $fkey.XXXXXX)
  vern=${JQVER:-jq-1.8.1}
  #####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  check_depends flgdone=/run/toolchain_$fkey bldtype=$1
  dldsrc_and_extract2wdir
  cd $wdir && do_source_build
}
#####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
: ${CHDIR:=$HOME/.cache/osci} ${GHCDN:=https://ghfast.top}
dfn_bldsrc_jq $1
