# マルチステージビルド
# ビルドステージ
FROM rust:1.83-slim AS builder

WORKDIR /app

# 依存関係をコピーしてビルド（キャッシュを活用）
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
RUN rm -rf src

# ソースコードをコピーしてビルド
COPY src ./src
# ダミーのmain.rsでビルドしたアーティファクトのタイムスタンプを更新して再ビルドをトリガー
RUN touch src/main.rs
RUN cargo build --release

# 実行ステージ
FROM debian:bookworm-slim

# 実行時に必要なライブラリをインストール（ca-certificatesなど）
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

# セキュリティ: 非rootユーザーを作成
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# ビルド済みバイナリをコピー
COPY --from=builder /app/target/release/google-gemini-image-creator /app/google-gemini-image-creator

# 非rootユーザーに切り替え
USER appuser

# 環境変数
ENV RUST_LOG=info

# エントリーポイント
ENTRYPOINT ["/app/google-gemini-image-creator"]

