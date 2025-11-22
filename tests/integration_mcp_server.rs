// 統合テストのサンプル
// 実際のGemini APIを使用したE2Eテストはここに実装

use google_gemini_image_creator::infrastructure::mcp::McpServer;

#[test]
fn test_mcp_server_initialization() {
    // 環境変数が設定されていない場合でもサーバーは初期化できる
    let server = McpServer::new("test-api-key".to_string());
    let tools = server.list_tools();
    assert_eq!(tools.len(), 1);
    assert_eq!(tools[0].name, "generate_image");
}

// 実際のAPIを使用したE2Eテストは、APIキーが必要なため、
// 環境変数GEMINI_API_KEYが設定されている場合のみ実行する
// #[tokio::test]
// async fn test_generate_image_e2e() {
//     let api_key = std::env::var("GEMINI_API_KEY").unwrap();
//     let server = McpServer::new(api_key);
//     // ... E2Eテストの実装
// }

