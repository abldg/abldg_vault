export SHELL:=/bin/bash
##[check_platform]##############################################################
ARCH_CURRENT:=$(shell arch)
OKAY_PLATFORM:=x86_64
ifneq (Y$(OKAY_PLATFORM)X,Y$(ARCH_CURRENT)X)
ERROR_TIP:=this-tools-only-support-on-[$(OKAY_PLATFORM)]
exit_for_run_on_not_supported_platform:
	@echo "[$(shell tput setaf 1)FATAL$(shell tput sgr0)]: ${ERROR_TIP} !!!"; true
endif
##[begin_normal]################################################################
#0#set-global-varants~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
vx?=1

vbse_make:=@
vbse_bash?=$(if $(VX),-x,$(if $(vx),-x,))
ifneq (-x,$(vbse_bash))
show_debug:=0
else
vbse_make:=
show_debug:=1
endif
all_entrance:=bash $(vbse_bash) $(wildcard *entry)

V2S+=SHV_CALL_BY_MAKE=1
V2S+=SHV_ENABLE_DEBUG=$(show_debug)
###load-modules~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fullpath_mods:=$(wildcard ${PWD}/*mods)
V2S+=SHV_FULLPATH_COMMLIB=$(wildcard ${fullpath_mods}/*commlib.sh)
# V2S+=SHV_FULLPATH_MODULES=${fullpath_mods}
#load-modules-{tgslst_req/tgslst_opt}-and-its-{tvs_xxxx}
-include $(wildcard ${fullpath_mods}/m*_*/*entry.mk)
### first_target~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.first_target/all_required_targets: ${tgslst_req}
	@printf "====>[done-required-list]<==== $^" | xargs -n1; true
### WITH-[SHV_CALL_BY_MAKE=1]~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
${tgslst_req} ${tgslst_opt}:
	@printf "##NOW-DOTASK:[ $(shell tput setaf 2)$@$(shell tput sgr0) ]##\n"
	@${V2S} ${tvs_$(firstword $(subst /, ,$(subst .,,$@)))} \
	TASK_HANDLER=shfn$(subst /,::,$(subst .,,/$@)) $(all_entrance); true

### WITHOUT-[SHV_CALL_BY_MAKE=1]~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.oth/univer .oth/ready_deps:
	@printf "##NOW-DOTASK:[ $(shell tput setaf 2)$@$(shell tput sgr0) ]##\n"
	@$(all_entrance) ${@F}; true
