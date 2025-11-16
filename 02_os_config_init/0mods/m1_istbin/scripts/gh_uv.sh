#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: gh_uv.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-15 16:13:36
## VERS: 1.0.1
##==================================----------==================================
shfn::istbin::uv() {
  : ${CHDIR:="$HOME/.cache/osci"}
  : ${GHCDN:="https://ghfast.top"}
  : ${ARIDX:="${SHV_PLAT_INDEX:-0}"}
  local alst=(x86_64 aarch64 arm 386)
  local atmp=${alst[$ARIDX]} && [ X${#atmp} = X0 ] && atmp=${alst}
  ###
  ###fetch-hashcode-and-filename
  local repown='astral-sh/uv'
  local apiurl="https://api.github.com/repos/$repown/releases/latest"
  local pjqone='.assets[]|select(.name|match("'$atmp'.*linux.*gnu.tar.gz$"))'
  pjqone+='|.digest+" '$GHCDN'/"+.browser_download_url'
  set -- $(curl -4sfSL $apiurl | jq -r "${pjqone}")
  [ $# -ne 2 ] && exit 1
  ###fetch-file-and-install
  mpt::install_tgz() {
    set -- $1 /usr/local/bin && mkdir -p $2 2>/dev/null
    cd $(mktemp -dt myt_inst_uv.XXXXXX) && bktdir=$PWD
    ###///////////////////////////////////////////////////////
    tar -zxf $1 --no-same-permissions --no-same-owner --strip-components=1
    printf "install -m 755 %s $2/\n" uv uvx | bash -x
    ###///////////////////////////////////////////////////////
    cd && rm -rf $bktdir
  }
  local hash_expect=${1#sha256:}
  : ARG1:=file_cached, ARG2=file_dlurl
  set -- $CHDIR/${2##*/} $2 && mkdir -p $CHDIR 2>/dev/null
  ##
  while true; do
    if [ -e $1 ]; then
      if [ X$(sha256sum $1 | awk '{printf $1}') = X$hash_expect ]; then
        mpt::install_tgz $1 && break
      fi
      rm -f $1 && sleep 3
    fi
    curl -#4fSLo $1 $2
  done
}
