# Google Gemini Image Creator MCP Server

Google GeminiのBanana（画像生成機能）を使用したMCP（Model Context Protocol）サーバーです。

## 環境変数設定

このプロジェクトは環境変数を使用して設定を行います。`env.example`を参考に、`.env`ファイルを作成するか、環境変数を設定してください。

### 必須環境変数

- `GEMINI_API_KEY`: Google Gemini APIキー（必須）

### オプション環境変数

#### Google Gemini API設定

- `GEMINI_API_BASE_URL`: Gemini APIのベースURL（デフォルト: `https://generativelanguage.googleapis.com/v1beta`）
- `GEMINI_DEFAULT_MODEL`: デフォルトのGeminiモデル名（デフォルト: `gemini-2.5-flash-image`）
- `GEMINI_ALLOWED_MODELS`: 許可されたGeminiモデルリスト（カンマ区切り、デフォルト: すべて許可）

#### JSON-RPC設定

- `JSONRPC_VERSION`: JSON-RPCバージョン（デフォルト: `2.0`）

#### アプリケーション設定

- `MAX_PROMPT_LENGTH`: プロンプトの最大長（デフォルト: `10000`）
- `RUST_LOG`: ログレベル（デフォルト: `info`）

## 使用方法

```bash
# 環境変数を設定
export GEMINI_API_KEY=your_api_key_here

# 実行
cargo run
```

## 環境変数の例

`env.example`ファイルを参考に、以下のような環境変数を設定できます：

```bash
GEMINI_API_KEY=your_api_key_here
GEMINI_API_BASE_URL=https://generativelanguage.googleapis.com/v1beta
GEMINI_DEFAULT_MODEL=gemini-2.5-flash-image
GEMINI_ALLOWED_MODELS=gemini-2.5-flash-image,gemini-3-pro-image-preview
JSONRPC_VERSION=2.0
MAX_PROMPT_LENGTH=10000
RUST_LOG=info
```

