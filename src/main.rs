extern crate ctrlc;

use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let running = Arc::new(AtomicBool::new(true));
    let r = running.clone();

    ctrlc::set_handler(move || {
        r.store(false, Ordering::SeqCst);
    })
    .expect("Error setting Ctrl-C handler");

    while running.load(Ordering::SeqCst) {
        let mut body = reqwest::get("https://www.rust-lang.org")
            .await?
            .text()
            .await?;

        let _ = body.split_off(30);
        println!("body = {:?}", body);
        std::thread::sleep(std::time::Duration::from_secs(3));
    }
    Ok(())
}
