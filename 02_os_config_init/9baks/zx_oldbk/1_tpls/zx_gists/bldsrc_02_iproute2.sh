#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: bldsrc_02_iproute2.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================
dfn_bldsrc_iproute2() {
  do_source_build() {
    #update-configure
    sed -r -i \
      -e '/^check_selinux$/s@^.*$@echo "no"@' \
      -e '/^check_tirpc$/s@^.*$@echo "no"@' \
      -e '/"YACC:=/aecho "LDFLAGS+=-s" >>$CONFIG' \
      configure && CC=${tpfx}-gcc AR=${tpfx}-ar bash configure
    ##
    make SUBDIRS='lib ip bridge'
    make install SUBDIRS='lib ip bridge' DESTDIR=$PWD/zinst_local
    [ Xaarch64Z = X$(arch)Z ] && make install SUBDIRS='lib ip bridge'
  }
  dldsrc_and_extract2wdir() {
    declare -r $@
    hsh='0b3b1c0b8f11a0e82c764bc291ce74bf03e778dc575b8097f5c440680150563b'
    url=https://github.com/iproute2/iproute2/archive/refs/tags/$vern.tar.gz
    chf="$CHDIR/iproute2-$vern.tar.gz" && mkdir -p ${CHDIR} 2>/dev/null
    while true; do
      [ ! -e $chf ] && curl -4sfSLo $chf $GHCDN/$url
      if [ -e $chf ]; then
        if [ X${hsh}Z = X$(sha256sum $chf |awk '{printf $1}')Z ]; then
          tar --strip-components=1 -zxf $chf -C $wdir
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
  fkey=${FUNCNAME#dfn_} && rm -rf /tmp/$fkey.* 2>/dev/null
  tpfx=$(arch)-linux-gnu
  vern=${SHV_VER_IPROUTE2:-v6.15.0}
  wdir=$(mktemp -d -t $fkey.XXXXXX)
  #####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  check_depends flgdone=/run/toolchain_$fkey bldtype=$1
  dldsrc_and_extract2wdir
  cd $wdir && do_source_build
}
#####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
: ${CHDIR:=$HOME/.cache/osci} ${GHCDN:=https://ghfast.top}
dfn_bldsrc_iproute2 $1
