.PHONY: test

test: dummy
	cp elm.mk dummy/elm.mk
	cd dummy && $(MAKE) -f elm.mk install
	touch dummy/images/test.jpg
	touch dummy/images/test.png
	cd dummy && $(MAKE) && $(MAKE) prod
	./tests.sh
	rm -r dummy

dummy:
	mkdir -p $@
