#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: lg_golang.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================
shfn::lang::golang() {
  : ${CHDIR:="$HOME/.cache/osci"}
  # : ${GHCDN:="https://ghfast.top"}
  : ${ARIDX:="${SHV_PLAT_INDEX:-0}"}
  local alst=(amd64 arm64 armv6l 386 loong64 riscv64 s390x)
  local atmp=${alst[$ARIDX]} && [ X${#atmp} = X0 ] && atmp=${alst}
  ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  local baseurl="https://golang.google.cn/dl/"
  # local baseurl="https://go.dev/dl/"
  local jqone='.[0].files[]'
  jqone+='|select(.filename|match("linux-'$atmp'.tar.gz"))'
  jqone+='|.sha256+" '$baseurl'"+.filename'
  set -- $(curl -4sfL "$baseurl?mode=json" | jq -r "$jqone")
  [ $# -ne 2 ] && exit 1
  ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  mpt::install_tgz() {
    : "TODO_INSTALL_STEPS"
    rm -rf /usr/local/go 2>/dev/null
    tar -C /usr/local -xf $1 \
      --no-same-permissions \
      --no-same-owner && {
      local txb=/usr/local/go/bin/go && $txb version
      $txb env -w GOSUMDB=off
      $txb env -w GO111MODULE=on
      $txb env -w GOMODCACHE=$HOME/.cache/golang
      $txb env -w GOCACHE=/tmp/gobldcache
      $txb env -w GOPROXY=https://goproxy.io,https://goproxy.cn,direct
      $txb env -w GOPRIVATE=gitee.com/abldg,gitlab.com
    }
  }
  ###fetch-file-and-install
  local hash_expect=$1
  : ARG1:=file_cached, ARG2=file_downloadurl, ARG3=installed_filepath
  set -- ${CHDIR%/}/${2##*/} $2
  mkdir -p $CHDIR /usr/local 2>/dev/null
  ##
  while true; do
    if [ -e $1 ]; then
      if [ X$(sha256sum $1 | awk '{printf $1}') = X$hash_expect ]; then
        mpt::install_tgz $1 && break
      fi
      rm -f $1 && sleep 3
    fi
    {
      echo "Now downloading from [$2] ..." &&
        curl -#s4fSLo $1 $2 &&
        echo "[ok] download [$1] done."
    } 2>/dev/null
  done
}
