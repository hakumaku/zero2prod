.PHONY: format build test coverage run

format:
	@cargo fmt

lint:
	@cargo clippy

build:
	@cargo build

test:
	@cargo test

coverage:
	@cargo tarpaulin --ignore-tests

run:
	@cargo run
