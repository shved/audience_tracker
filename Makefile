.PHONY: doc

default: lint test doc

setup:
	bundle install

test:
	bin/rspec

lint:
	bin/rubocop

run:
	rackup config.ru

