.PHONY: doc

default: lint test

setup:
	bundle install

test:
	bin/rspec

lint:
	bin/rubocop

console:
	bin/console

run:
	rackup config.ru
