ROPFX_ISTBIN=istbin
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
tvs_${ROPFX_ISTBIN}+=SHV_FORCE=$(if $(vf),$(vf),0)
tvs_${ROPFX_ISTBIN}+=SHV_PLAT_INDEX=$(if $(va),$(va),)
tvs_${ROPFX_ISTBIN}+=SHV_NVIM_VRN=$(if $(NVIM_VRN),$(NVIM_VRN),)
tvs_${ROPFX_ISTBIN}+=SHV_TTYD_VRN=$(if $(TTYD_VRN),$(TTYD_VRN),1.7.7)
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#####
tgslst_opt+=${ROPFX_ISTBIN}/apt_basic
tgslst_opt+=${ROPFX_ISTBIN}/apt_dkdkc
tgslst_opt+=${ROPFX_ISTBIN}/apt_libnvidia_container
#####
tgslst_opt+=${ROPFX_ISTBIN}/mdbook
tgslst_opt+=${ROPFX_ISTBIN}/shfmt
tgslst_opt+=${ROPFX_ISTBIN}/jq
tgslst_opt+=${ROPFX_ISTBIN}/yq
tgslst_opt+=${ROPFX_ISTBIN}/tini
tgslst_opt+=${ROPFX_ISTBIN}/ttyd
tgslst_opt+=${ROPFX_ISTBIN}/cmake
tgslst_opt+=${ROPFX_ISTBIN}/nvim
tgslst_opt+=${ROPFX_ISTBIN}/uv
tgslst_opt+=${ROPFX_ISTBIN}/dkc
# tgslst_opt+=${ROPFX_ISTBIN}/1panel
#####
tgslst_opt+=${ROPFX_ISTBIN}/cnmir/kubectl
#####
tgslst_opt+=${ROPFX_ISTBIN}/cnmir/helm
tgslst_opt+=${ROPFX_ISTBIN}/github/helm
#####
tgslst_opt+=${ROPFX_ISTBIN}/alibaba/gitrepo
tgslst_opt+=${ROPFX_ISTBIN}/google/gitrepo
#####

#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
ROPFX_LANG:=lang
tvs_${ROPFX_LANG}+=SHV_MJN_NODEJS=$(if $(mjn_nodejs),$(mjn_nodejs),22)
# tvs_${ROPFX_LANG}+=SHV_MJN_GOLANG=$(if $(mjn_golang),$(mjn_golang),25)
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
tgslst_opt+=${ROPFX_LANG}/golang
tgslst_opt+=${ROPFX_LANG}/rustlang
tgslst_opt+=${ROPFX_LANG}/nodejs
tgslst_opt+=${ROPFX_LANG}/ziglang

