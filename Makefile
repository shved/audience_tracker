.PHONY: doc

default: lint test doc

setup:
	bundle install

test:
	ruby spec/dummy_test.rb

lint:
	bin/rubocop

run:
	rackup config.ru

