ROPFX_DKCRUN=dkcrun
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
tvs_${ROPFX_DKCRUN}+=SHV_RUN_NOW=$(if $(now),$(now),)
tvs_${ROPFX_DKCRUN}+=SHV_DKCBASE=$(if $(dkcbase),$(dkcbase),/opt/dpanel_projs)
tvs_${ROPFX_DKCRUN}+=SHV_DKCYAML=$(if $(dkcyaml),$(dkcyaml),compose.yml)
tvs_${ROPFX_DKCRUN}+=SHV_PORT_DPANEL=$(if $(ptdpanel),$(ptdpanel),18080)
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# shfn::dkcrun::base::xxxx
#####
tgslst_opt+=${ROPFX_DKCRUN}/base/dpanel
tgslst_opt+=${ROPFX_DKCRUN}/base/filesvr
tgslst_opt+=${ROPFX_DKCRUN}/base/registry
tgslst_opt+=${ROPFX_DKCRUN}/base/mysql
tgslst_opt+=${ROPFX_DKCRUN}/base/redis

