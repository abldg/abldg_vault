#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: 41_gen_files.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================
###!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!###
sft.gen_newmac() {
  _inm() {
    while [ $# -ge 1 ]; do
      shift && printf ':%s' "$(date +%s%N | md5sum | head -c 2)"
    done
  }
  case $1 in
  1 | FIX | fix) printf '00:25:7C' && _inm 1 2 3 ;;
  *) _inm 1 2 3 4 5 6 ;;
  esac | awk '{print toupper($0)}' | sed 's,^:,,'

  unset -f _inm
}
###!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!###
sft.gen_password() {
  local usage="Usage: ${FUNCNAME} [-d,--digit-only] [PASSWD_LEN{=6}]"
  local cset='12345!@#$%qwertQWERTasdfgASDFGzxcvbZXCVB' crnd='/dev/urandom'
  local plen=6
  while :; do
    case $1 in
    '') break ;;
    -h | --help | help) echo $usage && return 0 ;;
    -d | --digit-only) cset='0-9' ;;
    *) [ X$1 != X ] && [ X${1//[0-9]/} = X ] && plen=$1 ;;
    esac
    shift
  done
  if [ ! -e $crnd ]; then
    echo '[FATAL] not find out '$crnd', skip !!!' && return 1
  fi
  tr <$crnd -dc $cset | head -c${plen} && echo
}
###!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!###
