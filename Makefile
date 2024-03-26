.PHONY: format build test coverage run docker

format:
	@cargo fmt

lint:
	@cargo clippy

build:
	@cargo build

test:
	@cargo test -- --nocapture

coverage:
	@cargo tarpaulin --ignore-tests

run:
	@cargo run

docker:
	@docker build --tag zero2prod --file Dockerfile .
