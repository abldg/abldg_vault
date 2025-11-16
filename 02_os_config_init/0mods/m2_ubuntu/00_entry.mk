ROPFX_UBUNTU=ubuntu
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# tvs_${ROPFX_UBUNTU}+=SHV_ENBPIP=$(if $(ep),$(ep),1)
# tvs_${ROPFX_UBUNTU}+=SHV_NTPSVR=$(if $(ns),$(ns),)
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
tgslst_opt+=${ROPFX_UBUNTU}/disable/svc_timers
tgslst_opt+=${ROPFX_UBUNTU}/enable/vfio_pci
tgslst_opt+=${ROPFX_UBUNTU}/fix/wait120s_ifn_online
tgslst_opt+=${ROPFX_UBUNTU}/fix/ubt2204_netplan_apply_warn
#####
tgslst_opt+=${ROPFX_UBUNTU}/update/ntplyml
tgslst_opt+=${ROPFX_UBUNTU}/update/apt_source_list
#####
tgslst_opt+=${ROPFX_UBUNTU}/allinit
