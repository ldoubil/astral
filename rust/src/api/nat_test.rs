use tokio::net::UdpSocket;
use std::net::SocketAddr;
use std::time::Duration;

#[derive(Debug, Clone, PartialEq)]
pub enum NatType {
    OpenInternet,
    FullCone,
    RestrictedCone,
    PortRestrictedCone,
    Symmetric,
    SymmetricUdpFirewall,
    Blocked,
    Unknown,
}

impl NatType {
    pub fn get_description(&self) -> String {
        match self {
            NatType::OpenInternet => "开放互联网 (Open Internet)".to_string(),
            NatType::FullCone => "完全锥形 NAT (Full Cone NAT)".to_string(),
            NatType::RestrictedCone => "受限锥形 NAT (Restricted Cone NAT)".to_string(),
            NatType::PortRestrictedCone => "端口受限锥形 NAT (Port Restricted Cone NAT)".to_string(),
            NatType::Symmetric => "对称型 NAT (Symmetric NAT)".to_string(),
            NatType::SymmetricUdpFirewall => "对称型 UDP 防火墙 (Symmetric UDP Firewall)".to_string(),
            NatType::Blocked => "UDP 被阻止 (UDP Blocked)".to_string(),
            NatType::Unknown => "未知类型 (Unknown)".to_string(),
        }
    }
}

/// NAT 检测结果（RFC 5780）
#[derive(Debug, Clone)]
pub struct NetworkTestResult {
    pub nat_type_v4: String,
    pub nat_type_v6: String,
    pub ipv4_latency: i64,
    pub ipv6_latency: i64,
}

/// 测试 UDP IPv4 NAT 类型（RFC 5780）
async fn test_udp_ipv4(stun_server: &str) -> (bool, i64, NatType) {
    let start = std::time::Instant::now();
    
    match detect_nat_type_rfc5780(stun_server, true).await {
        Ok(nat_type) => {
            let latency = start.elapsed().as_millis() as i64;
            (true, latency, nat_type)
        }
        Err(_) => (false, -1, NatType::Blocked),
    }
}

/// 测试 UDP IPv6 NAT 类型（RFC 5780）
async fn test_udp_ipv6_nat(stun_server: &str) -> (bool, i64, NatType) {
    let start = std::time::Instant::now();
    
    match detect_nat_type_rfc5780(stun_server, false).await {
        Ok(nat_type) => {
            let latency = start.elapsed().as_millis() as i64;
            (true, latency, nat_type)
        }
        Err(_) => (false, -1, NatType::Blocked),
    }
}

/// RFC 5780 NAT 类型检测算法
/// is_ipv4: true 为 IPv4, false 为 IPv6
async fn detect_nat_type_rfc5780(stun_server: &str, is_ipv4: bool) -> Result<NatType, String> {
    // 解析 STUN 服务器地址
    let server_address = format!("{}:3478", stun_server);
    let addrs = tokio::net::lookup_host(&server_address)
        .await
        .map_err(|e| format!("解析 STUN 服务器地址失败: {}", e))?;
    
    // 根据协议版本选择地址
    let server_addr = if is_ipv4 {
        addrs.filter(|addr| addr.is_ipv4()).next()
            .ok_or_else(|| format!("无法解析到 IPv4 地址: {}", stun_server))?
    } else {
        addrs.filter(|addr| addr.is_ipv6()).next()
            .ok_or_else(|| format!("无法解析到 IPv6 地址: {}", stun_server))?
    };

    // 绑定本地 socket
    let bind_addr = if is_ipv4 { "0.0.0.0:0" } else { "[::]:0" };
    let socket = UdpSocket::bind(bind_addr)
        .await
        .map_err(|e| format!("绑定 UDP socket 失败: {}", e))?;

    let local_addr = socket.local_addr()
        .map_err(|e| format!("获取本地地址失败: {}", e))?;

    // Test I: 发送 STUN Binding Request 到主服务器
    let transaction_id = generate_transaction_id();
    let request = create_binding_request(&transaction_id);
    
    socket.send_to(&request, server_addr).await
        .map_err(|e| format!("发送 Test I 请求失败: {}", e))?;

    let mut buf = vec![0u8; 1024];
    let timeout_result = tokio::time::timeout(
        Duration::from_secs(3),
        socket.recv_from(&mut buf)
    ).await;

    let (len, _) = match timeout_result {
        Ok(Ok(result)) => result,
        _ => {
            // Test I 失败：UDP 被阻止或防火墙
            return Ok(NatType::Blocked);
        }
    };

    // 解析 Test I 响应
    if len < 20 || buf[0] != 0x01 || buf[1] != 0x01 {
        return Ok(NatType::Unknown);
    }

    // 解析 MAPPED-ADDRESS 和 CHANGED-ADDRESS
    let (mapped_addr, changed_addr) = parse_stun_response(&buf[..len])?;

    // 检查是否是开放互联网（本地地址 == 映射地址）
    if mapped_addr.ip() == local_addr.ip() && mapped_addr.port() == local_addr.port() {
        return Ok(NatType::OpenInternet);
    }

    // 如果服务器不支持 CHANGED-ADDRESS（大多数现代 STUN 服务器），
    // 我们通过创建第二个 socket 来判断是否是对称型 NAT
    let socket2 = UdpSocket::bind(bind_addr).await
        .map_err(|e| format!("绑定第二个 socket 失败: {}", e))?;

    let transaction_id2 = generate_transaction_id();
    let request2 = create_binding_request(&transaction_id2);
    
    socket2.send_to(&request2, server_addr).await.ok();
    
    let mut buf2 = vec![0u8; 1024];
    let timeout_result2 = tokio::time::timeout(
        Duration::from_secs(3),
        socket2.recv_from(&mut buf2)
    ).await;

    if let Ok(Ok((len2, _))) = timeout_result2 {
        if let Ok((mapped_addr2, _)) = parse_stun_response(&buf2[..len2]) {
            // 比较两次映射地址的端口
            if mapped_addr.port() != mapped_addr2.port() {
                // 映射端口不同：对称型 NAT
                return Ok(NatType::Symmetric);
            }
        }
    }

    // Test II: 如果服务器支持 CHANGE-REQUEST，尝试请求从不同 IP 和端口响应
    if let Some(changed) = changed_addr {
        let request_change_both = create_binding_request_with_change(&transaction_id, true, true);
        
        socket.send_to(&request_change_both, server_addr).await.ok();
        
        let timeout_result = tokio::time::timeout(
            Duration::from_secs(3),
            socket.recv_from(&mut buf)
        ).await;

        if timeout_result.is_ok() {
            // 收到 Test II 响应：完全锥形 NAT
            return Ok(NatType::FullCone);
        }

        // Test III: 请求从相同 IP 但不同端口响应
        let request_change_port = create_binding_request_with_change(&transaction_id, false, true);
        
        socket.send_to(&request_change_port, changed).await.ok();
        
        let timeout_result3 = tokio::time::timeout(
            Duration::from_secs(3),
            socket.recv_from(&mut buf)
        ).await;

        if timeout_result3.is_ok() {
            // 收到 Test III 响应：受限锥形 NAT
            return Ok(NatType::RestrictedCone);
        }
    }

    // 默认返回端口受限锥形 NAT（最常见的类型）
    Ok(NatType::PortRestrictedCone)
}

/// 生成随机的事务 ID
fn generate_transaction_id() -> [u8; 12] {
    let mut id = [0u8; 12];
    use std::time::SystemTime;
    let now = SystemTime::now()
        .duration_since(SystemTime::UNIX_EPOCH)
        .unwrap()
        .as_nanos() as u64;
    
    id[0..8].copy_from_slice(&now.to_be_bytes());
    id[8..12].copy_from_slice(&[0x11, 0x22, 0x33, 0x44]);
    id
}

/// 创建 STUN Binding Request
fn create_binding_request(transaction_id: &[u8; 12]) -> Vec<u8> {
    let mut request = Vec::new();
    request.extend_from_slice(&[0x00, 0x01]); // Message Type: Binding Request
    request.extend_from_slice(&[0x00, 0x00]); // Message Length: 0
    request.extend_from_slice(&[0x21, 0x12, 0xA4, 0x42]); // Magic Cookie
    request.extend_from_slice(transaction_id);
    request
}

/// 创建带 CHANGE-REQUEST 属性的 Binding Request
fn create_binding_request_with_change(transaction_id: &[u8; 12], change_ip: bool, change_port: bool) -> Vec<u8> {
    let mut request = Vec::new();
    request.extend_from_slice(&[0x00, 0x01]); // Message Type: Binding Request
    
    // Message Length: 8 (CHANGE-REQUEST attribute)
    request.extend_from_slice(&[0x00, 0x08]);
    request.extend_from_slice(&[0x21, 0x12, 0xA4, 0x42]); // Magic Cookie
    request.extend_from_slice(transaction_id);
    
    // CHANGE-REQUEST attribute (0x0003)
    request.extend_from_slice(&[0x00, 0x03]); // Type
    request.extend_from_slice(&[0x00, 0x04]); // Length: 4
    
    let mut flags = 0u32;
    if change_ip {
        flags |= 0x04;
    }
    if change_port {
        flags |= 0x02;
    }
    request.extend_from_slice(&flags.to_be_bytes());
    
    request
}

/// 解析 STUN 响应，提取 MAPPED-ADDRESS 和 CHANGED-ADDRESS
fn parse_stun_response(data: &[u8]) -> Result<(SocketAddr, Option<SocketAddr>), String> {
    if data.len() < 20 {
        return Err("响应太短".to_string());
    }

    let msg_length = u16::from_be_bytes([data[2], data[3]]) as usize;
    let mut mapped_addr = None;
    let mut changed_addr = None;
    
    let mut pos = 20;
    while pos + 4 <= data.len() && pos < 20 + msg_length {
        let attr_type = u16::from_be_bytes([data[pos], data[pos + 1]]);
        let attr_length = u16::from_be_bytes([data[pos + 2], data[pos + 3]]) as usize;
        
        if pos + 4 + attr_length > data.len() {
            break;
        }
        
        match attr_type {
            0x0001 | 0x0020 => {
                // MAPPED-ADDRESS (0x0001) or XOR-MAPPED-ADDRESS (0x0020)
                if let Ok(addr) = parse_address_attribute(&data[pos + 4..pos + 4 + attr_length], attr_type == 0x0020, &data[4..20]) {
                    mapped_addr = Some(addr);
                }
            }
            0x0005 => {
                // CHANGED-ADDRESS (0x0005)
                if let Ok(addr) = parse_address_attribute(&data[pos + 4..pos + 4 + attr_length], false, &data[4..20]) {
                    changed_addr = Some(addr);
                }
            }
            _ => {}
        }
        
        pos += 4 + attr_length;
        // 属性需要 4 字节对齐
        if attr_length % 4 != 0 {
            pos += 4 - (attr_length % 4);
        }
    }

    mapped_addr.ok_or_else(|| "未找到 MAPPED-ADDRESS".to_string())
        .map(|addr| (addr, changed_addr))
}

/// 解析地址属性
fn parse_address_attribute(data: &[u8], is_xor: bool, magic_and_tid: &[u8]) -> Result<SocketAddr, String> {
    if data.len() < 8 {
        return Err("地址属性太短".to_string());
    }

    let family = data[1];
    let mut port = u16::from_be_bytes([data[2], data[3]]);
    
    if is_xor {
        // XOR with magic cookie
        port ^= 0x2112;
    }

    match family {
        0x01 => {
            // IPv4
            if data.len() < 8 {
                return Err("IPv4 地址数据不足".to_string());
            }
            let mut ip_bytes = [data[4], data[5], data[6], data[7]];
            if is_xor {
                // XOR with magic cookie
                for i in 0..4 {
                    ip_bytes[i] ^= magic_and_tid[i];
                }
            }
            let ip = std::net::Ipv4Addr::from(ip_bytes);
            Ok(SocketAddr::new(ip.into(), port))
        }
        0x02 => {
            // IPv6
            if data.len() < 20 {
                return Err("IPv6 地址数据不足".to_string());
            }
            let mut ip_bytes = [0u8; 16];
            ip_bytes.copy_from_slice(&data[4..20]);
            if is_xor {
                // XOR with magic cookie + transaction id
                for i in 0..16 {
                    ip_bytes[i] ^= magic_and_tid[i];
                }
            }
            let ip = std::net::Ipv6Addr::from(ip_bytes);
            Ok(SocketAddr::new(ip.into(), port))
        }
        _ => Err(format!("未知地址族: {}", family)),
    }
}

/// 综合网络测试 - Flutter 友好的 API
/// NAT 类型检测（RFC 5780）
pub fn test_network_connectivity(
    stun_server: String,
) -> Result<NetworkTestResult, String> {
    let rt = tokio::runtime::Runtime::new()
        .map_err(|e| format!("创建运行时失败: {}", e))?;

    let result = rt.block_on(async {
        // 并行执行 IPv4 和 IPv6 NAT 检测
        let (udp_v4_result, udp_v6_result) = tokio::join!(
            test_udp_ipv4(&stun_server),
            test_udp_ipv6_nat(&stun_server)
        );

        NetworkTestResult {
            nat_type_v4: udp_v4_result.2.get_description(),
            nat_type_v6: udp_v6_result.2.get_description(),
            ipv4_latency: udp_v4_result.1,
            ipv6_latency: udp_v6_result.1,
        }
    });

    Ok(result)
}

/// 检测 IPv4 NAT 类型（向后兼容）
pub fn detect_nat_type(stun_server: String) -> Result<String, String> {
    let rt = tokio::runtime::Runtime::new()
        .map_err(|e| format!("创建运行时失败: {}", e))?;

    let nat_type = rt.block_on(async {
        detect_nat_type_rfc5780(&stun_server, true).await
    })?;

    Ok(nat_type.get_description())
}
