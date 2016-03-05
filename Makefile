.PHONY: test

test: dummy
	cp elm.mk dummy/Makefile
	cd dummy && $(MAKE) install && $(MAKE)
	./tests.sh
	rm -r dummy

dummy:
	mkdir -p $@
