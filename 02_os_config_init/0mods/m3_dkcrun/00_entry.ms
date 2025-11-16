#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: 01_entry.sf
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 16:23:19
## VERS: 1.0.1
##==================================----------==================================
docker compose version &>/dev/null
if [ $? -eq 0 ]; then
  mt::load_funcs() {
    local thzmod_fullpath=${BASH_SOURCE%/*} newfile=
    for newfile in ${thzmod_fullpath}/scripts/*_*.sh; do . $newfile; done
  }
  # : "#{{{{ BGN-ENTRY: $BASH_SOURCE"
  mt::load_funcs
  unset -f mt::load_funcs
  # : "#}}}} END-ENTRY: $BASH_SOURCE"
fi
##!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!##
myt::ready::dkimg() {
  #ARG...: images-id
  [ $# -eq 0 ] && return
  local tosave=/opt/myfiles/docker_images && mkdir -p $tosave 2>/dev/null
  local lstimg="docker images --format={{.Repository}}:{{.Tag}}"
  local outgz= imgid= && for imgid in $@; do
    outgz=$tosave/$(arch)_${imgid//[.:\/]/_}.tar.gz
    if [ X0 = X$($lstimg | grep -cE "^${imgid}$") ]; then
      [ -e $outgz ] && docker load -i $outgz
    fi
    docker pull $imgid
    [ ! -e $outgz ] && docker save $imgid | gzip >$outgz
  done
}

shfn::dkcrun::base::redis() {
  : "${FUNCNAME}"
}
