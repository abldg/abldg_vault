#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: gh_mdbook.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-16 11:34:31
## VERS: 1.0.1
##==================================----------==================================

#https://github.com/rust-lang/mdBook/releases/download
#/v0.4.52/mdbook-v0.4.52-x86_64-unknown-linux-musl.tar.gz

shfn::istbin::mdbook() {
  : ${CHDIR:="$HOME/.cache/osci"}
  : ${GHCDN:="https://ghfast.top"}
  : ${ARIDX:="${SHV_PLAT_INDEX:-0}"}
  ###fetch-hashcode-and-filename
  local alst=(x86_64 aarch64)
  local atmp=${alst[$ARIDX]} && [ X${#atmp} = X0 ] && atmp=${alst}
  ###
  local repown='rust-lang/mdBook'
  local apiurl="https://api.github.com/repos/$repown/releases"
  local pjqone='first('
  pjqone+='.[]|select(.tag_name|test("-(beta|alpha|rc)")|not)|'
  pjqone+='.assets[]|select(.name|match("'$atmp'.*linux-musl.tar.gz$"))'
  pjqone+='|.digest+" '${GHCDN}'/"+.browser_download_url'
  pjqone+=')'
  set -- $(curl -4sSL $apiurl | jq -r "$pjqone")
  [ $# -ne 2 ] && exit 1
  ###fetch-file-and-install
  mpt::instgz() {
    # cd $(mktemp -dt myt_inst_mdbook.XXXXXX) && bktdir=$PWD
    ###///////////////////////////////////////////////////////
    tar -zxf $1 --no-same-owner
    set -- mdbook && mkdir -p /usr/local/bin 2>/dev/null
    [ -e $1 ] && install -m 755 $1 /usr/local/bin/$1 && rm -f $1
    ###///////////////////////////////////////////////////////
    # cd && rm -rf $bktdir
  }
  local hash_expect=${1#sha256:}
  : ARG1:=file_cached, ARG2=file_dlurl
  set -- ${CHDIR}/${2##*/} $2 && mkdir -p $CHDIR 2>/dev/null
  ##
  while true; do
    if [ -e $1 ]; then
      if [ X$(sha256sum $1 | awk '{printf $1}') = X$hash_expect ]; then
        mpt::instgz $1 && break
      fi
      rm -f $1 && sleep 3
    fi
    curl -#4fSLo $1 $2
  done
}
