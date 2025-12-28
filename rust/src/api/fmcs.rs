mod forward;
mod multicast;

use tokio::io;
use forward::ForwardServer;
use multicast::MulticastSender;

#[tokio::main]
async fn main() -> io::Result<()> {
    // 启动 TCP 转发
    let mut server = ForwardServer::new("0.0.0.0:25568", "43.248.189.79:25565");
    server.start().await?;
    
    // 启动组播发送器
    let mut multicast = MulticastSender::new(
        "224.0.2.60",
        4445,
        b"[MOTD]\xc2\xa7k||\xc2\xa7r \xc2\xa76\xc2\xa7l[Astral]\xc2\xa7r \xc2\xa7b\xc2\xa7l\xe6\x9c\x8d\xe5\x8a\xa1\xe5\x99\xa8\xe6\x8e\xa8\xe8\x8d\x90\xc2\xa7r \xc2\xa7d\xc2\xa7o\xe8\x8b\xa5\xe9\x9b\xaa\xc2\xa7r \xc2\xa7k||\xc2\xa7r[/MOTD][AD]25568[/AD]".to_vec(),
        1000,
    )?;
    multicast.start().await?;

    println!("TCP转发和组播服务已启动");
    println!("监听: 0.0.0.0:25568 -> 43.248.189.79:25565");
    println!("组播: 224.0.2.60:4445");
    
    // 持续运行
    loop {
        tokio::time::sleep(tokio::time::Duration::from_secs(3600)).await;
    }
}

