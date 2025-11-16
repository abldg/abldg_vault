#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: bv_gitrepo.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-15 15:21:55
## VERS: 1.0.0
##==================================----------==================================
shfn::istbin::google::gitrepo() {
  set -- https://mirrors.tuna.tsinghua.edu.cn/git/git-repo /usr/local/bin/repo
  curl -4sfSL $1 | sed -r \
    's|(^\s+REPO_URL =) .*$|\1 "'${1}'"|' >$2 && chmod a+x $2
}
##//////////////////////////////////////////////////////////////////////////////
shfn::istbin::alibaba::gitrepo() {
  : ${CHDIR:="$HOME/.cache/osci"}
  : ${GHCDN:="https://ghfast.top"}
  local repown="alibaba/git-repo-go"
  local apiurl="https://api.github.com/repos/$repown/releases/latest"
  set -- git-repo
  local pjqone='.assets[]|select(.name|match("'$1'.*Linux-64.tar.gz$"))'
  pjqone+='|"'${GHCDN}'/"+.browser_download_url'
  set -- $(curl -4sSL $apiurl | jq -r "$pjqone")

  [ $# -ne 1 ] && exit 1

  ###fetch-file-and-install
  mpt::install_tgz() {
    set -- $1 /usr/local/bin/git-repo
    cd $(mktemp -dt myt_inst_${2##*/}.XXXXXX) && bktdir=$PWD
    ###///////////////////////////////////////////////////////
    tar -zxf $1 --no-same-permissions --no-same-owner --strip-components=1
    mkdir -p ${2%/*} 2>/dev/null
    install -m 755 ${2##*/} $2
    ###///////////////////////////////////////////////////////
    cd && rm -rf $bktdir
  }
  : ARG1:=file_cached, ARG2=file_downloadurl
  set -- ${CHDIR}/${1##*/} ${1} && mkdir -p $CHDIR 2>/dev/null
  while true; do
    if [ -e $1 ]; then
      mpt::install_tgz $1
      break
    fi
    sleep 3s && curl -#4fSLo $1 $2
  done
}
