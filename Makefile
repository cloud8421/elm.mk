.PHONY: test

test: dummy
	rm -r dummy/*
	cp elm.mk dummy/Makefile
	cd dummy && $(MAKE) install && $(MAKE)
	./tests.sh

dummy:
	mkdir -p $@
