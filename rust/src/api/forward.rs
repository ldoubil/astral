use tokio::io::{self, AsyncReadExt, AsyncWriteExt};
use tokio::net::{TcpListener, TcpStream};
use tokio::task::JoinHandle;
use tokio_util::sync::CancellationToken;
use std::sync::Arc;
use std::sync::atomic::{AtomicU64, AtomicUsize, Ordering};
use std::sync::Mutex;
use lazy_static::lazy_static;
use tokio::runtime::Runtime;

lazy_static! {
    static ref RT: Runtime = Runtime::new().expect("创建 Tokio 运行时失败");
    static ref FORWARD_SERVERS: Mutex<Vec<ForwardServer>> = Mutex::new(Vec::new());
}

#[derive(Clone)]
pub struct ServerStats {
    pub connections: Arc<AtomicUsize>,
    pub bytes_sent: Arc<AtomicU64>,
    pub bytes_received: Arc<AtomicU64>,
}

impl ServerStats {
    pub fn new() -> Self {
        Self {
            connections: Arc::new(AtomicUsize::new(0)),
            bytes_sent: Arc::new(AtomicU64::new(0)),
            bytes_received: Arc::new(AtomicU64::new(0)),
        }
    }

    pub fn get_connections(&self) -> usize {
        self.connections.load(Ordering::Relaxed)
    }

    pub fn get_bytes_sent(&self) -> u64 {
        self.bytes_sent.load(Ordering::Relaxed)
    }

    pub fn get_bytes_received(&self) -> u64 {
        self.bytes_received.load(Ordering::Relaxed)
    }
}

pub struct ForwardServer {
    listen_addr: String,
    forward_addr: String,
    handle: Option<JoinHandle<()>>,
    cancel_token: Option<CancellationToken>,
    pub stats: ServerStats,
}

impl ForwardServer {
    pub fn new(listen_addr: impl Into<String>, forward_addr: impl Into<String>) -> Self {
        Self {
            listen_addr: listen_addr.into(),
            forward_addr: forward_addr.into(),
            handle: None,
            cancel_token: None,
            stats: ServerStats::new(),
        }
    }

    pub async fn start(&mut self) -> io::Result<()> {
        if self.handle.is_some() {
            return Err(io::Error::new(io::ErrorKind::AlreadyExists, "服务已启动"));
        }

        let listener = TcpListener::bind(&self.listen_addr).await?;
        let forward_addr = self.forward_addr.clone();
        let cancel_token = CancellationToken::new();
        let cancel_token_clone = cancel_token.clone();
        let stats = self.stats.clone();

        let handle = tokio::spawn(async move {
            loop {
                tokio::select! {
                    _ = cancel_token_clone.cancelled() => {
                        break;
                    }
                    result = listener.accept() => {
                        match result {
                            Ok((client_stream, _)) => {
                                let forward_addr = forward_addr.clone();
                                let stats = stats.clone();
                                stats.connections.fetch_add(1, Ordering::Relaxed);
                                tokio::spawn(async move {
                                    let _ = handle_connection(client_stream, &forward_addr, stats).await;
                                });
                            }
                            Err(_) => break,
                        }
                    }
                }
            }
        });

        self.handle = Some(handle);
        self.cancel_token = Some(cancel_token);
        Ok(())
    }

    pub async fn stop(&mut self) {
        if let Some(cancel_token) = self.cancel_token.take() {
            cancel_token.cancel();
        }
        if let Some(handle) = self.handle.take() {
            let _ = handle.await;
        }
    }

    pub fn is_running(&self) -> bool {
        self.handle.is_some()
    }
}

async fn handle_connection(mut client_stream: TcpStream, forward_addr: &str, stats: ServerStats) -> io::Result<()> {
    let mut remote_stream = TcpStream::connect(forward_addr).await?;

    let (mut client_read, mut client_write) = client_stream.split();
    let (mut remote_read, mut remote_write) = remote_stream.split();

    let stats_send = stats.clone();
    let client_to_remote = async move {
        let mut buf = vec![0u8; 8192];
        loop {
            let n = client_read.read(&mut buf).await?;
            if n == 0 {
                return io::Result::Ok(());
            }
            remote_write.write_all(&buf[..n]).await?;
            stats_send.bytes_sent.fetch_add(n as u64, Ordering::Relaxed);
        }
    };

    let stats_recv = stats.clone();
    let remote_to_client = async move {
        let mut buf = vec![0u8; 8192];
        loop {
            let n = remote_read.read(&mut buf).await?;
            if n == 0 {
                return io::Result::Ok(());
            }
            client_write.write_all(&buf[..n]).await?;
            stats_recv.bytes_received.fetch_add(n as u64, Ordering::Relaxed);
        }
    };

    let result = tokio::select! {
        result = client_to_remote => result,
        result = remote_to_client => result,
    };
    
    stats.connections.fetch_sub(1, Ordering::Relaxed);
    result
}

// Flutter 友好的 API

/// 创建并启动一个端口转发服务器
/// 返回服务器索引，用于后续操作
pub fn create_forward_server(listen_addr: String, forward_addr: String) -> JoinHandle<Result<usize, String>> {
    RT.spawn(async move {
        let mut server = ForwardServer::new(listen_addr.clone(), forward_addr.clone());
        
        match server.start().await {
            Ok(_) => {
                let mut servers = FORWARD_SERVERS.lock().unwrap();
                servers.push(server);
                let index = servers.len() - 1;
                println!("端口转发服务器已启动: {} -> {}, 索引: {}", listen_addr, forward_addr, index);
                Ok(index)
            }
            Err(e) => Err(format!("启动端口转发服务器失败: {}", e))
        }
    })
}

/// 停止指定索引的端口转发服务器
pub fn stop_forward_server(index: usize) -> JoinHandle<Result<(), String>> {
    RT.spawn(async move {
        let mut servers = FORWARD_SERVERS.lock().unwrap();
        
        if index >= servers.len() {
            return Err(format!("无效的服务器索引: {}", index));
        }
        
        servers[index].stop().await;
        println!("端口转发服务器已停止，索引: {}", index);
        Ok(())
    })
}

/// 停止所有端口转发服务器
pub fn stop_all_forward_servers() -> JoinHandle<Result<(), String>> {
    RT.spawn(async move {
        let mut servers = FORWARD_SERVERS.lock().unwrap();
        
        for (index, server) in servers.iter_mut().enumerate() {
            server.stop().await;
            println!("端口转发服务器已停止，索引: {}", index);
        }
        
        servers.clear();
        println!("所有端口转发服务器已停止");
        Ok(())
    })
}

/// 获取指定服务器的统计信息
pub fn get_forward_server_stats(index: usize) -> Result<(usize, u64, u64), String> {
    let servers = FORWARD_SERVERS.lock().unwrap();
    
    if index >= servers.len() {
        return Err(format!("无效的服务器索引: {}", index));
    }
    
    let stats = &servers[index].stats;
    Ok((
        stats.get_connections(),
        stats.get_bytes_sent(),
        stats.get_bytes_received(),
    ))
}

/// 获取所有正在运行的服务器数量
pub fn get_forward_server_count() -> usize {
    let servers = FORWARD_SERVERS.lock().unwrap();
    servers.len()
}

/// 检查指定服务器是否正在运行
pub fn is_forward_server_running(index: usize) -> bool {
    let servers = FORWARD_SERVERS.lock().unwrap();
    
    if index >= servers.len() {
        return false;
    }
    
    servers[index].is_running()
}
