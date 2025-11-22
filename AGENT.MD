# Google Gemini Image Creator MCP Server

## プロジェクト概要

Google GeminiのBanana（画像生成機能）を使用したMCP（Model Context Protocol）サーバーをRustで実装するプロジェクトです。

## 技術スタック

- **言語**: Rust (Edition 2021)
- **プロトコル**: MCP (Model Context Protocol)
- **外部API**: Google Gemini API (画像生成: Banana)
- **コンテナ**: Docker
- **CI/CD**: GitHub Actions

## 開発手法

- **テスト駆動開発 (TDD)**: 本番環境での利用を想定した品質担保のため、TDDを採用
- **スペック駆動開発**: 本ドキュメントを仕様書として開発を進める

## アーキテクチャ

### クリーンアーキテクチャ採用

ドメインロジックを固定し、依存関係の逆転を実現するクリーンアーキテクチャを採用します。

```
src/
├── domain/              # ドメイン層（ビジネスロジック）
│   ├── image_generation.rs
│   └── models.rs
├── application/         # アプリケーション層（ユースケース）
│   └── use_cases/
│       └── generate_image.rs
├── infrastructure/      # インフラ層（外部依存）
│   ├── gemini/
│   │   └── client.rs
│   └── mcp/
│       └── server.rs
├── presentation/        # プレゼンテーション層（MCPインターフェース）
│   └── handlers.rs
└── main.rs
```

### レイヤー責務

1. **Domain層**: 画像生成のドメインロジック、エンティティ、値オブジェクト
2. **Application層**: ユースケース実装、ドメイン層への依存
3. **Infrastructure層**: Gemini APIクライアント、MCPサーバー実装
4. **Presentation層**: MCPリクエスト/レスポンスのハンドリング

## 機能要件

### MCPツール: 画像生成

**ツール名**: `generate_image`

**説明**: Google GeminiのBananaを使用してテキストプロンプトから画像を生成します。

**入力パラメータ**:
- `prompt` (string, required): 画像生成のためのテキストプロンプト
- `model` (string, optional): 使用するGeminiモデル（デフォルト: `gemini-2.5-flash-image`）
  - 選択肢: `gemini-2.5-flash-image` (Nano Banana), `gemini-3-pro-image-preview` (Nano Banana Pro Preview)

**出力**:
- 生成された画像データ（バイナリ形式）
- メタデータ（生成時刻、使用モデルなど）

**エラーハンドリング**:
- API認証エラー
- レート制限エラー
- 無効なプロンプトエラー
- ネットワークエラー

## 外部依存

### Google Gemini API

**参考ドキュメント**: https://ai.google.dev/gemini-api/docs/image-generation?hl=ja

**使用モデル**:
- `gemini-2.5-flash-image` (Nano Banana): 高速・低レイテンシ向け、1024x1024解像度
- `gemini-3-pro-image-preview` (Nano Banana Pro Preview): 高品質・4K解像度対応

**認証**: APIキーを使用（環境変数 `GEMINI_API_KEY` から取得）

**API仕様**:
- エンドポイント: `https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent`
- リクエスト形式: JSON
- レスポンス形式: 画像データ（base64エンコードまたはバイナリ）

## テスト戦略

### テストレベル

1. **ユニットテスト**: ドメインロジック、ユースケース
2. **統合テスト**: Gemini APIクライアント、MCPサーバー
3. **E2Eテスト**: MCPツール呼び出しから画像生成まで

### テストカバレッジ目標

- ドメイン層: 100%
- アプリケーション層: 90%以上
- インフラ層: 80%以上（モック使用）

### テストツール

- `cargo test`: Rust標準テストフレームワーク
- `mockito` または `wiremock`: HTTP APIモック
- `tokio-test`: 非同期テストユーティリティ

## デプロイ

### Docker

**Dockerfile要件**:
- マルチステージビルドを使用
- 本番用の最適化されたバイナリサイズ
- セキュリティベストプラクティス（非rootユーザーなど）

**環境変数**:
- `GEMINI_API_KEY`: Google Gemini APIキー（必須）
- `GEMINI_DEFAULT_MODEL`: デフォルトGeminiモデル名（オプション、デフォルト: `gemini-2.5-flash-image`）
- `GEMINI_ALLOWED_MODELS`: 許可されたGeminiモデルリスト（オプション、カンマ区切り）
- その他の環境変数については「MCPサーバー設定」セクションを参照

### GitHub Actions

**CI/CDパイプライン**:
1. テスト実行（`cargo test`）
2. リントチェック（`cargo clippy`）
3. フォーマットチェック（`cargo fmt --check`）
4. Dockerイメージビルド
5. Docker HubまたはGitHub Container Registryへのプッシュ

**トリガー**:
- `main`ブランチへのプッシュ
- タグ作成時

## セキュリティ要件

- APIキーの環境変数管理（シークレットとして扱う）
- 入力検証（プロンプトのサニタイゼーション）
- レート制限の実装
- エラーメッセージからの情報漏洩防止

## パフォーマンス要件

- 画像生成リクエストのレイテンシ: 可能な限り低く（モデル依存）
- メモリ使用量の最適化
- 並行リクエストの処理能力

## ログ・監視

- 構造化ログ（`tracing`クレート推奨）
- リクエスト/レスポンスのログ記録
- エラーログの詳細記録
- メトリクス収集（オプション）

## MCPサーバー設定

このセクションでは、MCPクライアント（Claude Desktopなど）でこのサーバーを使用するための設定方法を説明します。

### 設定ファイルの場所

MCPクライアント（Claude Desktopなど）の設定ファイルに、このサーバーを追加します。

**Claude Desktopの場合:**
- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`
- Linux: `~/.config/Claude/claude_desktop_config.json`

### 設定ファイルのサンプル

プロジェクトルートに以下のサンプルファイルを用意しています：
- `mcp-config.example.json`: 開発環境用（cargo runを使用）
- `mcp-config-claude-desktop.example.json`: 本番環境用（ビルド済みバイナリを使用）
- `mcp-config-docker.example.json`: Dockerコンテナ使用時

### 設定例

#### 1. 開発環境での設定（cargo runを使用）

```json
{
  "mcpServers": {
    "google-gemini-image-creator": {
      "command": "cargo",
      "args": [
        "run",
        "--release"
      ],
      "cwd": "/path/to/google-gemini-image-creator",
      "env": {
        "GEMINI_API_KEY": "your_gemini_api_key_here",
        "GEMINI_DEFAULT_MODEL": "gemini-2.5-flash-image",
        "GEMINI_ALLOWED_MODELS": "gemini-2.5-flash-image,gemini-3-pro-image-preview"
      }
    }
  }
}
```

#### 2. 本番環境での設定（ビルド済みバイナリを使用）

```json
{
  "mcpServers": {
    "google-gemini-image-creator": {
      "command": "/path/to/google-gemini-image-creator/target/release/google-gemini-image-creator",
      "env": {
        "GEMINI_API_KEY": "your_gemini_api_key_here",
        "GEMINI_DEFAULT_MODEL": "gemini-2.5-flash-image",
        "GEMINI_ALLOWED_MODELS": "gemini-2.5-flash-image,gemini-3-pro-image-preview"
      }
    }
  }
}
```

#### 3. Dockerコンテナを使用する場合

```json
{
  "mcpServers": {
    "google-gemini-image-creator": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e", "GEMINI_API_KEY=your_gemini_api_key_here",
        "-e", "GEMINI_DEFAULT_MODEL=gemini-2.5-flash-image",
        "-e", "GEMINI_ALLOWED_MODELS=gemini-2.5-flash-image,gemini-3-pro-image-preview",
        "google-gemini-image-creator:latest"
      ]
    }
  }
}
```

### 設定可能な環境変数

| 環境変数 | 説明 | 必須 | デフォルト値 |
|---------|------|------|------------|
| `GEMINI_API_KEY` | Google Gemini APIキー | ✅ 必須 | - |
| `GEMINI_DEFAULT_MODEL` | デフォルトで使用するGeminiモデル名 | ❌ | `gemini-2.5-flash-image` |
| `GEMINI_ALLOWED_MODELS` | 許可されたGeminiモデルリスト（カンマ区切り） | ❌ | すべて許可 |
| `GEMINI_API_BASE_URL` | Gemini APIのベースURL | ❌ | `https://generativelanguage.googleapis.com/v1beta` |
| `JSONRPC_VERSION` | JSON-RPCバージョン | ❌ | `2.0` |
| `MAX_PROMPT_LENGTH` | プロンプトの最大長（文字数） | ❌ | `10000` |
| `RUST_LOG` | ログレベル | ❌ | `info` |

### Geminiモデルの選択

**利用可能なモデル:**
- `gemini-2.5-flash-image` (Nano Banana): 高速・低レイテンシ向け、1024x1024解像度
- `gemini-3-pro-image-preview` (Nano Banana Pro Preview): 高品質・4K解像度対応

**設定方法:**
1. **デフォルトモデルの設定**: `GEMINI_DEFAULT_MODEL`環境変数でデフォルトモデルを指定
2. **許可モデルの制限**: `GEMINI_ALLOWED_MODELS`環境変数で使用可能なモデルを制限（カンマ区切り）
3. **ツール呼び出し時の指定**: MCPツールの`model`パラメータで個別にモデルを指定可能

**例:**
```json
{
  "env": {
    "GEMINI_DEFAULT_MODEL": "gemini-3-pro-image-preview",
    "GEMINI_ALLOWED_MODELS": "gemini-2.5-flash-image,gemini-3-pro-image-preview"
  }
}
```

### セキュリティ注意事項

⚠️ **重要**: APIキーなどの機密情報は設定ファイルに直接記述しないことを推奨します。

**推奨される方法:**
1. 環境変数から読み取る（システム環境変数を使用）
2. シークレット管理ツールを使用
3. `.env`ファイルを使用（`.gitignore`に追加）

**設定ファイルの例（環境変数参照）:**

注意: Claude Desktopの設定ファイルでは、環境変数の参照方法が異なる場合があります。システム環境変数を直接使用する場合は、設定ファイルの`env`セクションを省略し、システム環境変数から読み取るようにしてください。

```json
{
  "mcpServers": {
    "google-gemini-image-creator": {
      "command": "/path/to/google-gemini-image-creator/target/release/google-gemini-image-creator",
      "env": {
        "GEMINI_DEFAULT_MODEL": "gemini-2.5-flash-image"
      }
    }
  }
}
```

この場合、`GEMINI_API_KEY`はシステム環境変数から読み取られます。

## 開発環境セットアップ

### 必要な環境

- Rust 1.70以上
- Docker（オプション）
- Google Gemini APIキー

### ローカル開発

```bash
# 依存関係のインストール
cargo build

# テスト実行
cargo test

# 実行（環境変数を直接指定）
GEMINI_API_KEY=your_api_key cargo run

# または、env.exampleを参考に環境変数を設定してから実行
cargo run
```

### ビルド

```bash
# リリースビルド
cargo build --release

# バイナリの場所
# target/release/google-gemini-image-creator
```

## 参考資料

- [Google Gemini API 画像生成ドキュメント](https://ai.google.dev/gemini-api/docs/image-generation?hl=ja)
- [MCP Protocol Specification](https://modelcontextprotocol.io/)
- [Rust Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

