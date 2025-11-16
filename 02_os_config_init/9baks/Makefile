Q?=@
OPTS:= -n 0.0.0.0 -p 80 -d /tmp/mdbooks/ubtdocs

serve: halt
	$(Q)(mdbook $@ $(OPTS) &>/var/log/mdbook.log &); true

halt:
	$(Q)( pidof mdbook |xargs kill -9 2>/dev/null); true
