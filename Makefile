dummy:
	rm -rf $@
	mkdir $@
	cp roots.mk dummy/
	cd dummy && $(MAKE) -f roots.mk && cd ..
.PHONY: dummy

test:
	ruby test.rb
.PHONY: test
