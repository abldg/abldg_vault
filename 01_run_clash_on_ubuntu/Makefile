ifneq (Yx86_64X,Y$(shell arch)X)
ifneq (Yaarch64X,Y$(shell arch)X)
only_for_run_on_amd64_or_arm64_machine:
	@echo "[WARN_TIP]: this tool $@ !!!" | sed 's@_@ @g'; true
endif
endif
###------------------------------BGN--------------------------------------------
en?=1
#dbg?=1
##
VE:=$(if $(ve),$(ve),$(if $(en),en,cn))
VD:=$(if $(vd),$(vd),$(if $(dbg),1,0))
VX:=$(if $(vx),-x,)
VQ:=@
ifeq (-x,$(VX))
VQ:=
VD:=1
endif
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V2S+=SW_CALBYMK=1
V2S+=SW_DBGTHIZ=$(VD)
V2S+=SW_THZLANG=$(VE)
V2S+=SW_USEMIRR=$(if $(m),1,0)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OPERLST+=proxy/enable
OPERLST+=proxy/disable

##
yy:=uptenv
OPERLST+=$(yy)
egs_$(yy)+=NEW_LNKURL='$(if $(LNKURL),$(LNKURL),$(if $(u),$(u),))'
egs_$(yy)+=NEW_SECRET='$(if $(SECRET),$(SECRET),$(if $(p),$(p),))'

##
OPERLST+=help
OPERLST+=infoproj

##
$(OPERLST):;$(VQ)$(V2S) ACTKW=${@F} ${egs_${@F}} bash $(VX) bin/myctl; true
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.PHONY: $(OPERLST)
###------------------------------END--------------------------------------------
