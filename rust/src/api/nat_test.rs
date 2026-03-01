use easytier::common::stun::{StunInfoCollector, UdpNatTypeDetector};
use easytier::proto::common::NatType as EasyNatType;
use std::time::{Duration, Instant};
use tokio::net::UdpSocket;

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
            NatType::OpenInternet => "Open Internet".to_string(),
            NatType::FullCone => "Full Cone NAT".to_string(),
            NatType::RestrictedCone => "Restricted Cone NAT".to_string(),
            NatType::PortRestrictedCone => "Port Restricted Cone NAT".to_string(),
            NatType::Symmetric => "Symmetric NAT".to_string(),
            NatType::SymmetricUdpFirewall => "Symmetric UDP Firewall".to_string(),
            NatType::Blocked => "UDP Blocked".to_string(),
            NatType::Unknown => "Unknown".to_string(),
        }
    }
}

#[derive(Debug, Clone)]
pub struct NetworkTestResult {
    pub nat_type_v4: String,
    pub nat_type_v6: String,
    pub ipv4_latency: i64,
    pub ipv6_latency: i64,
}

fn normalize_stun_server(input: &str) -> String {
    let mut server = input.trim().to_string();
    if server.starts_with("stun://") {
        server = server.trim_start_matches("stun://").to_string();
    }

    let has_explicit_port = if server.starts_with('[') {
        server.contains("]:")
    } else {
        server.matches(':').count() == 1
    };

    if has_explicit_port {
        server
    } else {
        format!("{}:3478", server)
    }
}

fn build_udp_stun_server_list(preferred_server: &str) -> Vec<String> {
    let mut servers = Vec::<String>::new();

    let preferred = normalize_stun_server(preferred_server);
    if !preferred.is_empty() {
        servers.push(preferred);
    }

    for default_server in StunInfoCollector::get_default_servers() {
        if !servers.contains(&default_server) {
            servers.push(default_server);
        }
    }

    servers
}

fn map_easy_nat_type(nat: EasyNatType) -> NatType {
    match nat {
        EasyNatType::OpenInternet => NatType::OpenInternet,
        EasyNatType::NoPat => NatType::OpenInternet,
        EasyNatType::FullCone => NatType::FullCone,
        EasyNatType::Restricted => NatType::RestrictedCone,
        EasyNatType::PortRestricted => NatType::PortRestrictedCone,
        EasyNatType::SymUdpFirewall => NatType::SymmetricUdpFirewall,
        EasyNatType::Symmetric | EasyNatType::SymmetricEasyInc | EasyNatType::SymmetricEasyDec => {
            NatType::Symmetric
        }
        EasyNatType::Unknown => NatType::Unknown,
    }
}

async fn detect_nat_type_ipv4(stun_server: &str) -> Result<NatType, String> {
    let stun_servers = build_udp_stun_server_list(stun_server);
    if stun_servers.is_empty() {
        return Err("No STUN servers available".to_string());
    }

    let detector = UdpNatTypeDetector::new(stun_servers, 2);
    let detect_result = tokio::time::timeout(Duration::from_secs(8), detector.detect_nat_type(0))
        .await
        .map_err(|_| "NAT detection timeout".to_string())
        .and_then(|ret| ret.map_err(|e| format!("NAT detection failed: {e}")))?;

    Ok(map_easy_nat_type(detect_result.nat_type()))
}

fn create_binding_request() -> [u8; 20] {
    let mut request = [0u8; 20];
    request[0] = 0x00;
    request[1] = 0x01; // Binding Request
    request[2] = 0x00;
    request[3] = 0x00; // Message Length
    request[4] = 0x21;
    request[5] = 0x12;
    request[6] = 0xA4;
    request[7] = 0x42; // Magic Cookie

    let now_nanos = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_nanos())
        .unwrap_or(0);
    let tid_seed = now_nanos.to_be_bytes();
    request[8..20].copy_from_slice(&tid_seed[4..16]);
    request
}

fn is_success_stun_response(data: &[u8]) -> bool {
    if data.len() < 20 {
        return false;
    }

    let is_binding_success = data[0] == 0x01 && data[1] == 0x01;
    let has_magic_cookie = data[4] == 0x21 && data[5] == 0x12 && data[6] == 0xA4 && data[7] == 0x42;

    is_binding_success && has_magic_cookie
}

async fn test_udp_ipv4(stun_server: &str) -> (bool, i64, NatType) {
    let start = Instant::now();

    match detect_nat_type_ipv4(stun_server).await {
        Ok(nat_type) => (true, start.elapsed().as_millis() as i64, nat_type),
        Err(_) => (false, -1, NatType::Blocked),
    }
}

async fn test_udp_ipv6(stun_server: &str) -> (bool, i64, NatType) {
    let start = Instant::now();
    let server = normalize_stun_server(stun_server);

    let mut addrs = match tokio::net::lookup_host(&server).await {
        Ok(addrs) => addrs,
        Err(_) => return (false, -1, NatType::Unknown),
    };

    let Some(server_v6) = addrs.find(|addr| addr.is_ipv6()) else {
        return (false, -1, NatType::Unknown);
    };

    let socket = match UdpSocket::bind("[::]:0").await {
        Ok(s) => s,
        Err(_) => return (false, -1, NatType::Unknown),
    };

    let request = create_binding_request();
    if socket.send_to(&request, server_v6).await.is_err() {
        return (false, -1, NatType::Unknown);
    }

    let mut buf = [0u8; 1500];
    let recv = tokio::time::timeout(Duration::from_secs(3), socket.recv_from(&mut buf)).await;

    match recv {
        Ok(Ok((len, _))) if is_success_stun_response(&buf[..len]) => (
            true,
            start.elapsed().as_millis() as i64,
            NatType::OpenInternet,
        ),
        _ => (false, -1, NatType::Unknown),
    }
}

/// NAT test entry for Flutter.
pub fn test_network_connectivity(stun_server: String) -> Result<NetworkTestResult, String> {
    let rt =
        tokio::runtime::Runtime::new().map_err(|e| format!("Failed to create runtime: {e}"))?;

    let result = rt.block_on(async {
        let (v4, v6) = tokio::join!(test_udp_ipv4(&stun_server), test_udp_ipv6(&stun_server));

        NetworkTestResult {
            nat_type_v4: v4.2.get_description(),
            nat_type_v6: v6.2.get_description(),
            ipv4_latency: v4.1,
            ipv6_latency: v6.1,
        }
    });

    Ok(result)
}

/// Backward-compatible API: detect IPv4 NAT type.
pub fn detect_nat_type(stun_server: String) -> Result<String, String> {
    let rt =
        tokio::runtime::Runtime::new().map_err(|e| format!("Failed to create runtime: {e}"))?;

    let nat_type = rt.block_on(async { detect_nat_type_ipv4(&stun_server).await })?;
    Ok(nat_type.get_description())
}
