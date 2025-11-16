#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: 04_ghrel_nvim.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================
shfn::istbin::nvim() {
  mpt::via::srcfile() {
    local repown='neovim/neovim'
    local tgzurl="https://github.com/$repown/archive/refs/tags/stable.tar.gz"
    local cached_tgz=$CHDIR/nvim-source-stable.tar.gz
    mkdir -p $CHDIR 2>/dev/null
    rm -f $cached_tgz 2>/dev/null
    curl -4fsSLo $cached_tgz ${GHCDN}/$tgzurl
    [ X = X$(command -v cmake) ] && shfn::istbin::cmake
    ##[doinst]
    rm -rf /tmp/myt_bldsrc_nvim.*/ 2>/dev/null
    cd $(mktemp -d -t myt_bldsrc_nvim.XXXXXX) && bktdir=$PWD
    tar -xf $cached_tgz --no-same-owner --strip-components=1
    sed -i -r 's|://(github.com)|://ghfast.top/https://\1|' cmake.deps/deps.txt
    make nvim -j$(nproc) CMAKE_BUILD_TYPE=Release
    make install CMAKE_BUILD_TYPE=Release
  }
  ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  mpt::via::binfile() {
    local alst=(x86_64 arm64)
    local atmp=${alst[$ARIDX]} && [ X${#atmp} = X0 ] && atmp=${alst}
    local repown='neovim/neovim'
    local apiurl="https://api.github.com/repos/$repown/releases/latest"
    local pjqone='.assets[]|select(.name|match("linux-'"$atmp"'.tar.gz$"))'
    pjqone+='|.digest+" '${GHCDN}'/"+.browser_download_url'
    set -- $(curl -4sSL $apiurl | jq -r "$pjqone")
    [ $# -ne 2 ] && exit 1
    ###fetch-file-and-install
    mpt::instgz() {
      cd $(mktemp -d -t myt_inst_nvim.XXXXXX) && bktdir=$PWD
      ###///////////////////////////////////////////////////////
      tar -zxf $1 --no-same-owner --strip-components=1 &&
        rm -rf /usr/local/[ls]*/nvim share/[aim]*/ 2>/dev/null
      cp -rf bin lib share /usr/local/
      ###///////////////////////////////////////////////////////
      cd && rm -rf $bktdir
    }
    local hash_expect=${1#sha256:}
    : ARG1:=file_cached, ARG2=file_downloadurl, ARG3=installed_filepath
    set -- $CHDIR/${2##*/} $2 /usr/local
    mkdir -p $CHDIR $3 2>/dev/null
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
  ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  : ${CHDIR:="$HOME/.cache/osci"}
  : ${GHCDN:="https://ghfast.top"}
  ##check-install-via-binfile-or-srcfile
  ldd_vern=$(ldd --version 2>/dev/null | awk -F. 'NR==1{printf $NF}')
  if [ X0 != X${#ldd_vern} ] && [ $ldd_vern -gt 27 ]; then
    : ${ARIDX:="${SHV_PLAT_INDEX:-0}"}
    (mpt::via::binfile)
  else
    (mpt::via::srcfile)
  fi
  ##----------------------------------------------------------------------------
  set -- /usr/local/bin/nvim && hash -r && if [ -x $1 ]; then
    printf "ln -sf $1 /usr/bin/%s\n" vim vi editor | bash -x
  fi
  ##----------------------------------------------------------------------------
  ##update[~/.config/nvim]
  set -- $HOME/.config/nvim && [ -d $1 ] && (
    cd $1 && [ ! -d .git ] &&
      newts=$(date +'%F-%T') &&
      git init && git add . -f &&
      git commit -m 'reinit@'${newts}
  ) 2>/dev/null
}
