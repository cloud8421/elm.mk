.PHONY: test

test: dummy
	cp elm.mk dummy/elm.mk
	cd dummy && $(MAKE) -f elm.mk install && $(MAKE)
	./tests.sh
	rm -r dummy

dummy:
	mkdir -p $@
