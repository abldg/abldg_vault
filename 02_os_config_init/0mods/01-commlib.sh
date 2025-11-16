: "#{{{{ BGN-COMMLIB: $BASH_SOURCE"
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
LOADED_SHL=DONE
{ source /etc/os-release; } 2>/dev/null
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
mt::pkgcmd_check() {
  local x= && for x in apt dnf yum $@; do
    if [ X != X$(command -v $x) ]; then
      export P_REMOVE="${SUDO}${x} remove -y"
      export P_UPDATE="${SUDO}${x} update -y"
      export P_INSTALL="${SUDO}${x} install -y"
      return
    fi
  done
}
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
mt::locate_defs() {
  {
    shopt -s extdebug
    set -- $(declare -F ${1:-${FUNCNAME[1]}})
    shopt -u extdebug
    if [ X${#3}Z != X0Z ]; then
      LOCFLE=$(realpath $3)
      LOCDIR=${LOCFLE%/*}
    fi
  } 2>/dev/null
}
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
mt::ispkgexist() {
  ##arg1: pkgname[,binfilename]
  {
    : ${PFXSB:='@===> '}
    ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    set -- ${1//,/ }
    ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    GPROMPTS+=(
      [cn_try_inst_pkg]="${PFXSB}尝试安装: [${CBLU}$1${CYLW}]"
      [en_try_inst_pkg]="${PFXSB}try-to-install: [${CBLU}$1${CYLW}]"
      [cn_pkg_instdone]="${PFXSB}已安装: [${CGRN}$1${CYAN}]"
      [en_pkg_instdone]="${PFXSB}installed: [${CGRN}$1${CYAN}]"
    )
    local vs=$(command -v ${2:-${1}} 2>/dev/null)
    if [ ${#vs} -eq 0 ]; then
      mc::ylw try_inst_pkg
      ${P_INSTALL} $1
      vs=$(command -v ${2:-${1}} 2>/dev/null)
    fi
    [ ${#vs} -ge 1 ] && mc::yan pkg_instdone
  } 2>/dev/null
}
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
mt::tip_step() {
  {
    [ X0 = X${SHV_ENABLE_DEBUG:-0} ] && return
    local ci=($(caller 0))
    local msg="$CBLU${ci[2]},$CYLW${ci},$CGRN${ci[1]}$CEND"
    echo -e "====>loc=($msg)${1:+,msg=[$CYAN$1$CEND]}<===="
  } 2>/dev/null
}
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
mt::prompt() {
  # mt::tip_step
  local cc= bk="${*}" zl="${SHV_LANGUAGE:-cn}"
  if [[ "X${bk//[a-z0-9_]/}" = "X" ]]; then
    [[ ${bk}X == @(cn|en|jp|fr|ru|de)_*X ]] && bk="${bk#*_}"
    set -- "${GPROMPTS[${zl}_${bk}]}"
    [ ${#1} -ge 1 ] && bk="${*}"
  fi
  printf -- "${!COLOR}${bk}${CEND}"
  # printf -- "${!COLOR}${bk}${CEND}" | sed -r 's@^\s+#TDL#@@g'
  ##
  [ X${LSW_NEWLINE:-1} = X1 ] && echo
  [ XCRED = X${COLOR} ] && [[ X${0}Z != X*bashZ ]] && exit 1
}
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{
  declare -gA GPROMPTS=()
  mt::pkgcmd_check
  ## [COLORS] ##
  mcary=(end:0 red:"31;1" grn:32 ylw:33 blu:34 plp:35 yan:36)
  for x in ${mcary[@]}; do
    p=(${x//:/ }) && eval "export C${p^^}='\e[${p[1]}m'" &&
      eval 'mc::'$p'(){ { COLOR=C'${p^^}' mt::prompt $@; } 2>/dev/null; }'
    # eval 'mc::'$p'(){ COLOR=C'${p^^}' mt::prompt $@; }'
  done 2>/dev/null
  ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  [ X$(id -u)Z != X0Z ] && SUDO="sudo "
  MYBASH="${SUDO}bash"
  [ X1 = X${SHV_DO_DEBUG:-0} ] && MYBASH="${SUDO}bash -x"
  export MYBASH SUDO
  export MYTEE="${SUDO}tee"
  export MYSED="${SUDO}sed"
  export MYTAR="${SUDO}tar"
  export MYCP="${SUDO}cp"
  export MYMV="${SUDO}mv"
  export MYINSTALL="${SUDO}install"
  export MYSYSTEMCTL="${SUDO}systemctl"
  ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if [ X0 = X${#SHV_PLAT_INDEX} ]; then
    case $(arch) in
    x86_64 | i386 | i686) SHV_PLAT_INDEX=0 ;;
    aarch64) SHV_PLAT_INDEX=1 ;;
    arm*) SHV_PLAT_INDEX=2 ;;
    esac
  fi
  export SHV_PLAT_INDEX
  ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  export GHCDN=https://ghfast.top
  export CHDIR=$HOME/.cache/osci
  mkdir -p $CHDIR /usr/local/bin 2>/dev/null
  ln -sf /bin/bash /bin/sh
} 2>/dev/null
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
mt::locate_defs mt::locate_defs && outterbse=$LOCDIR
for x in $outterbse/m*_*/*entry.ms; do
  #echo ": $x" &&
  source $x
done 2>/dev/null
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
unset -v x p mcary
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
: "#}}}} END-COMMLIB: $BASH_SOURCE"
