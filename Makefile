.PHONY: test

test: dummy
	cp elm.mk dummy/elm.mk
	cd dummy && $(MAKE) -f elm.mk install
	cd dummy && touch images/test.jpg && touch images/test.png && $(MAKE) && $(MAKE) prod
	./tests.sh
	rm -r dummy

dummy:
	mkdir -p $@
