all: check test

check:
	@echo "... executing shellcheck"
	@shellcheck ssh-vulnkey

test:
	@echo "... executing unit tests"
	@bash shunit2-tests.sh

.PHONY: check test
