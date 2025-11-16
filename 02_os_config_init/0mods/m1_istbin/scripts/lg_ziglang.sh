#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: lg_ziglang.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-27 16:39:09
## VERS: 0.2
##==================================----------==================================
shfn::lang::ziglang() {
  mpt::show_dlurl_for_ziglang() {
    local pjqone='to_entries|.[1].value|."'$(arch)'-linux".tarball'
    local release_json_dlurl="https://ziglang.org/download/index.json"
    local tarxz_file_dlurl=$(curl -4sSL $release_json_dlurl | jq -r "$pjqone")
    printf '===> please download via [ %s ]\n' $tarxz_file_dlurl
  }
  mpt::bldsrc() {
    : ${CHDIR:="$HOME/.cache/osci"}
    : ${GHCDN:="https://ghfast.top"}
    local repown="ziglang/zig"
    local apiurl="https://api.github.com/repos/$repown/releases"
    local pjqone='first('
    pjqone+='.[]|select(.tag_name|test("alpha|beta|rc")|not)'
    pjqone+='|.assets[]|select(.name|match("zig.*bootstrap.*tar.xz"))'
    pjqone+='|.digest+" '$GHCDN'/"+.browser_download_url'
    pjqone+=')'
    set -- $(curl -4sSL $apiurl | jq -r "$pjqone")
    [ $# -ne 2 ] && exit 1

    local hash_expect=${1#sha256:}
    set -- $CHDIR/${2##*/} $2 && mkdir -p $CHDIR 2>/dev/null
    ##
    mpt::instgz() {
      rm -rf /tmp/myt_inst_ziglang.* 2>/dev/null
      cd $(mktemp -d -t myt_inst_ziglang.XXXXXX) && bktdir=$PWD
      ###///////////////////////////////////////////////////////
      tar -xf $1 --no-same-owner --strip-components=1
      ###///////////////////////////////////////////////////////
      [ X = X$(command -v ccache) ] && apt install -y ccache
      ###///////////////////////////////////////////////////////
      # Debug, Release, RelWithDebInfo and MinSizeRel
      export CMAKE_BUILD_TYPE="Release"
      export CMAKE_BUILD_PARALLEL_LEVEL=$(nproc)
      export CMAKE_C_COMPILER_LAUNCHER=ccache
      export CMAKE_CXX_COMPILER_LAUNCHER=ccache
      set -- $(arch)-linux-gnu baseline && bash -x build $@ 2>/dev/null
      ###///////////////////////////////////////////////////////
    }
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
  ###源码编译耗时太长,仅作为备份信息而保留
  # mpt::bldsrc
  ###直接从官网下载二进制文件,这里只给出下载路径(国外小站点下载也慢)
  mpt::show_dlurl_for_ziglang
}
