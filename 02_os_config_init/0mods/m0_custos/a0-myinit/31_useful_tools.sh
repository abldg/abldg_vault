#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: 31_useful_tools.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================
open() {
  local vcmd='vim'
  [ X != X$(command -v vifm) ] && vcmd='vifm'
  set -- $@ && [ X0 = X${#1} ] && set -- ${PWD}
  set -- $vcmd $@ && $@
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
dha() {
  case $1 in
  "") ls -A | xargs du -sh | sort -h ;;
  *) {
    if [ -d $1 ]; then
      (cd $1 && ls -A | xargs du -sh | sort -h)
    else
      du -sh $1
    fi
  } ;;
  esac
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fj() {
  [ X0 = X${#1} ] && return
  [ X-Z = X${1:0:1}Z ] && return
  [ ! -e $1 ] && mkdir -p $1
  [ -d $1 ] && cd $1
}
# alias sft.fastjump='fj'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
alias sfs='sf -s'
sf() {
  _tryoutput_shfn() {
    set -- $1 /tmp/${1##.}.sh
    if [ X != X$(command -v shfmt) ]; then
      declare -f $1 | shfmt -i 2 -ln bash
    else
      declare -f $1 | sed -r 's#\t#    #;s#  # #g'
    fi | tee $2
    [ X$flgSave = X1 ] && {
      echo '#!/usr/bin/env bash'
      cat $2
      printf '%s $@\n' $1
    } >$1.sh
    rm -f $2
  }
  ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  [ X0 = X${#1} ] && declare -F && return
  local flgSave=0 && while [ $# -ge 1 ]; do
    if [ X-sZ = X${1}Z ]; then
      flgSave=1
    else
      [ X = X$(command -v $1) ] && return
      if [ X$1 != X$(declare -F $1) ]; then
        alias $1
        return
      fi
      _tryoutput_shfn $1
    fi
    shift
  done
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sfx() {
  (
    echo '+set -x'
    shopt -s expand_aliases
    set -x
    eval "$@"
    set +x #&& shopt -u expand_aliases
  )
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sft.kapid() {
  [ $# -ge 1 ] && {
    pidof $1 | xargs kill -9
  }
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sft.remove_duplines() {
  [ $# -ge 1 ] && awk '!a[$0]++' "$*"
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sft.gbk2utf8() {
  [ X != X$1 ] && (
    local afile= frm=
    while read afile; do
      frm=$(file -ib $afile | awk -F= '{printf $NF}')
      [ "Xutf-8" != "X$frm" ] && {
        mv $afile tmx
        [ "Xiso" = "X${frm%%-*}" ] && frm='GB18030'
        iconv -f "$frm" -t UTF-8 <tmx >$afile
        [ $? -ne 0 ] && mv tmx ${afile}
      }
    done <$1
    rm -f tmx
  )
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sft.groupString() {
  [ $# -ge 1 ] || return
  local x="$1" step=${2:-1} next=${3:-0}
  local vLen=${#x}
  while [ $next -le $vLen ]; do
    y=${x:next:step}
    [ "X$y" == "X" ] && break
    echo $y
    ((next += step))
  done
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sft.chk_pkgcmd() {
  set -- apt dnf yum
  local x=
  for x in $@; do
    if [ X != X$(command -v $x) ]; then
      export PKG_REMV="${x} remove -y"
      export PKG_UPDT="${x} update -y"
      export PKG_INST="${x} install -y"
      return
    fi
  done
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sfn.get_mypubip() {
  # dig @resolver1.opendns.com -t A -4 myip.opendns.com +short
  curl -f4sSL ifconfig.io
}
sfn.sync_datetime() {
  ntpdate ntp.aliyun.com
}
sfn.show_myips() {
  ip -4 a | awk '/inet /{sub("/.*","",$2);print $NF,$2}' |
    awk '/.*'$1'/' | column -t
}
sfn.shownicsdata() {
  tail +2 /proc/net/dev | awk '$2!=0' |
    sed 's@cast|bytes@cast Send:@;s@face\s|bytes@Ifnames Recv:@' | column -t
}
sfn.showlanips() {
  [ X = X$(command -v fping) ] && return
  local pjo='.[]|select(.dst != "default")|.dev+"@"+.dst'
  set -- $(ip -4 -j r | jq -r "$pjo" | awk '!/docker|virbr/')
  if [ $# -ne 0 ]; then
    { echo "=====Detected-Using-Ipv4s====="; } 2>/dev/null
    for r in $@; do
      echo "via-[$r]" && fping -4 -a -I ${r%@*} -g ${r#*@} 2>/dev/null
    done && unset -v r
  fi
}

###!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!###
sfw.ready_devcontainer() {
  local cnt_name=${1:-"${PWD##*/}"}
  local fsh_init=${2:-".devcontainer.init.sh"}
  {
    local tpl='{
    #TDL#  "name": "RV_MYID",
    #TDL#  "image": "docker.1ms.run/ubuntu:24.04",
    #TDL#  "postCreateCommand": "bash -x $PWD/'${fsh_init}'",
    #TDL#  "remoteUser": "root",
    #TDL#  "runArgs": [
    #TDL#    "--name=RV_MYID",
    #TDL#    "--hostname=RV_MYID",
    #TDL#    "--dns=114.114.114.114",
    #TDL#    "--network=host"
    #TDL#  ],
    #TDL#  "customizations": {
    #TDL#    "vscode": {
    #TDL#      "extensions": [
    #TDL#        "mkhl.shfmt",
    #TDL#        "geeebe.duplicate",
    #TDL#        "EditorConfig.EditorConfig",
    #TDL#        "kennylong.kubernetes-yaml-formatter"
    #TDL#      ]
    #TDL#    }
    #TDL#  }
    #TDL#}'
    echo "$tpl" | sed -r -e "s@\s+#TDL#@@g;s#RV_MYID#${cnt_name}#g" \
      -e "s|RV_IMGID|docker.1ms.run/ubuntu:24.04|g" | tee .devcontainer.json
    ###======================================================================###
    tpl='## Ubuntu ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #TDL#cd ${BASH_SOURCE%/*} && export DEBIAN_FRONTEND=noninteractive
    #TDL###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #TDL## 预先配置时区+安装所需包
    #TDL#ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&
    #TDL#  set -- ca-certificates tzdata && apt update -y &&
    #TDL#  apt install -y $@ && update-$1
    #TDL###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #TDL#{
    #TDL#  echo "##LJJX_UPDATE"
    #TDL#  echo "Types: deb"
    #TDL#  echo "URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu/"
    #TDL#  echo "Suites: RV_ID RV_ID-updates RV_ID-backports RV_ID-security"
    #TDL#  echo "Components: main restricted universe multiverse"
    #TDL#  echo "Architectures: RV_ARCH"
    #TDL#  echo "Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg"
    #TDL#} 2>/dev/null | sed "s#RV_ID#noble#g;s#RV_ARCH#amd64#" |
    #TDL#  tee /etc/apt/sources.list.d/ubuntu.sources
    #TDL###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #TDL#set -- 114.114.114.114 && echo "nameserver $1" >/etc/resolv.conf
    #TDL#set -- curl git jq make tar gzip bzip2 gawk \
    #TDL#  bash-completion iputils-ping iproute2 net-tools &&
    #TDL#  apt-get update -y && apt-get install -y $@
    #TDL###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #TDL#set -- https://gitee.com/abldg/osci ~/.osci &&
    #TDL#  git clone $@ && cd $2 &&
    #TDL#  set -- custos/dotmyinit istbin/{jq,shfmt,nvim} &&
    #TDL#  make $@ custos/extsinst/codesvr'
    echo "$tpl" | sed -r -e "s@\s+#TDL#@@g" | tee ${fsh_init}
  } 2>/dev/null
}
