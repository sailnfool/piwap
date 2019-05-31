# BIN=~/piwap/bin
.sh:
	ln $< $@
#	install -g piwap -o pi -C $@ $(EXECDIR)
INSTALL = func.pathmunge pathmunge restart func.errecho func.getprojdir \
				func.verifychange sourcedate 
PROJECT := piwap
EXECDIR := $(HOME)/$(PROJECT)/bin
#EXECS := $(addprefix $(EXECDIR)/,$(INSTALL))
all: $(INSTALL)
restart: func.errecho func.verifychange
install: $(EXECS)
	install -g piwap -o pi -C $< $(EXECDIR)
#	rm $<
clean: $(INSTALL)
	rm $<
$(EXECDIR):
	mkdir -p $(EXECDIR)
$(EXECS): $(INSTALL)
	install -g piwap -o pi -C $@ $(EXECDIR)
