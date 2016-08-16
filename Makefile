all: check test

check:
	@echo "... executing shellcheck"
	@shellcheck ssh-vulnkey

test:
	@echo "... executing unit tests"
	@bash ./shunit2-tests.sh

clean:
	rm -rf blacklist blacklist-debcache

.PHONY: check test clean
