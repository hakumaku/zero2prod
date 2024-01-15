use std::net::TcpListener;

#[tokio::test]
async fn test_health_check() {
    let addr = spawn_app();
    let endpoint = format!("{}/health_check", &addr);

    let client = reqwest::Client::new();

    let response = client
        .get(&endpoint)
        .send()
        .await
        .expect("Failed to execute request.");

    assert!(response.status().is_success());
    assert_eq!(Some(0), response.content_length());
}

fn spawn_app() -> String {
    let listener = TcpListener::bind("127.0.0.1:0").expect("Failed to bind random port");
    let port = listener.local_addr().unwrap().port();
    let server = zero2prod::run(listener).expect("Failed to bind address");

    let _ = tokio::spawn(server);

    format!("http://127.0.0.1:{}", port)
}
