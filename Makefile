TESTS = $(shell find plugins -name "spec")
GLOBALS = --globals $$,jQuery,Backbone,_,document,_instances

test:
	./node_modules/.bin/jasmine-node --coffee --verbose .

watch_tests:
	./node_modules/.bin/jasmine-node --coffee --verbose --autotest .

.PHONY: test