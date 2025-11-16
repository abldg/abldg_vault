ROPFX_CUSTOS=custos
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
tvs_${ROPFX_CUSTOS}+=SHV_ENBPIP=$(if $(ep),$(ep),1)
tvs_${ROPFX_CUSTOS}+=SHV_NTPSVR=$(if $(ns),$(ns),)
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#####
tgslst_req+=${ROPFX_CUSTOS}/allinit

tgslst_opt+=${ROPFX_CUSTOS}/dotmyinit
tgslst_opt+=${ROPFX_CUSTOS}/upt_dotssh
tgslst_opt+=${ROPFX_CUSTOS}/upt_sshconfig
tgslst_opt+=${ROPFX_CUSTOS}/upt_chronyconfig
tgslst_opt+=${ROPFX_CUSTOS}/extsinst/codesvr
#####

