.sh:
	rm -f $@
	cp $< $@
PREFIX=func
INSTALL = $(PREFIX).cwave $(PREFIX).errecho $(PREFIX).gen_range \
					$(PREFIX).getprojdir $(PREFIX).insufficient \
					$(PREFIX).onefilereformat $(PREFIX).pathmunge \
					$(PREFIX).stderrecho $(PREFIX).verifychange \
					sourcedate restart pathmunge
PROJECT := piwap

PROJPATH=/usr/local
EXECDIR := $(PROJPATH)/sbin
all: $(INSTALL)
restart: $(PREFIX).errecho $(PREFIX).verifychange
install: $(INSTALL)
	sudo install -g $(PROJECT) -o $(USER) -C $? $(EXECDIR)
clean: $(INSTALL)
	rm $^
$(EXECDIR):
	sudo mkdir -p $(EXECDIR)
	sudo addgroup $(PROJECT)
	sudo chown root $(EXECDIR)
	sudo chgrp $(PROJECT) $(EXECDIR)
	sudo chmod g+rwx $(EXECDIR)
