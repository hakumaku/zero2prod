.PHONY: format build test coverage run docker migrate

format:
	@cargo +nightly fmt

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

migrate:
	@sqlx migrate run
