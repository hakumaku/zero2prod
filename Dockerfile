###### Chef
FROM lukemathwalker/cargo-chef:latest AS chef

WORKDIR /app

RUN DEBIAN_FRONTEND=noninteractive \
    apt update && \
    apt install --no-install-recommends -y lld clang && \
    apt clean -y && \
    apt autoremove -y && \
    rm -rf /var/cache/apt/* /var/lib/apt/lists/*

###### Planner
FROM chef as planner

COPY . .
# Compute a lock-like file for our project
RUN cargo chef prepare --recipe-path recipe.json

###### Builder
FROM chef as builder
COPY --from=planner /app/recipe.json recipe.json
# Build our project dependencies, not our application!
RUN cargo chef cook --release  nnrecipe-path recipe.json
# Up to this point, if our dependency tree stays the same, all layers should be cached.
COPY . .

ENV SQLX_OFFLINE true
RUN cargo build --release --bin zero2prod

###### Application
FROM debian:bookworm-slim AS runtime

# Install OpenSSL - it is dynamically linked by some of our dependencies
# Install ca-certificates - it is needed to verify TLS certificates
# when establishing HTTPS connections
RUN DEBIAN_FRONTEND=noninteractive \
    apt update && \
    apt install --no-install-recommends -y openssl ca-certificates && \
    apt clean -y && \
    apt autoremove -y && \
    rm -rf /var/cache/apt/* /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/target/release/zero2prod zero2prod
COPY configuration configuration

ENV APP_ENVIRONMENT production
ENTRYPOINT ["./zero2prod"]
