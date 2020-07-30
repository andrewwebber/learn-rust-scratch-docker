FROM rust:1.45 as builder
RUN apt-get update
RUN apt-get install musl-tools -y
RUN rustup target add x86_64-unknown-linux-musl
WORKDIR /usr/src/app
COPY . .
RUN CARGO_HOME=./.cargo PKG_CONFIG_ALLOW_CROSS=1 cargo build --target x86_64-unknown-linux-musl --release
RUN cd /usr/src/app/target/x86_64-unknown-linux-musl/release && ls && pwd

FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
ENV SSL_CERT_DIR=/etc/ssl/certs
COPY --from=builder /usr/src/app/target/x86_64-unknown-linux-musl/release/app /usr/local/bin/app
CMD ["app"]
