.sh:
	rm -f $@
	cp $< $@
INSTALL = func.pathmunge pathmunge func.errecho func.getprojdir \
				func.verifychange sourcedate restart
PROJECT := piwap

EXECDIR := $(HOME)/$(PROJECT)/bin
all: $(INSTALL)
restart: func.errecho func.verifychange
install: $(INSTALL)
	install -g $(PROJECT) -o $(USER) -C $? $(EXECDIR)
clean: $(INSTALL)
	rm $^
$(EXECDIR):
	mkdir -p $(EXECDIR)
