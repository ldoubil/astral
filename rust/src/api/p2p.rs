
use easytier::common::config::{ConfigFileControl, PortForwardConfig};
pub use easytier::common::config::{ConfigLoader, NetworkIdentity, PeerConfig, TomlConfigLoader};
pub use easytier::common::global_ctx::{EventBusSubscriber, GlobalCtxEvent};
pub use easytier::instance_manager::NetworkInstanceManager;
pub use easytier::proto;
pub use easytier::proto::api::instance::{PeerRoutePair, Route};
pub use easytier::proto::common::NatType;
use lazy_static::lazy_static;
use serde_json::json;
use tokio::runtime::Runtime;
pub use tokio::task::JoinHandle;
use uuid::Uuid;

pub static DEFAULT_ET_DNS_ZONE: &str = "as.net.";

lazy_static! {
    static ref RT: Runtime = Runtime::new().expect("failed to create tokio runtime");
    static ref MANAGER: NetworkInstanceManager = NetworkInstanceManager::new();
}

fn parse_instance_id(instance_id: &str) -> Result<Uuid, String> {
    Uuid::parse_str(instance_id).map_err(|e| format!("invalid instance_id: {}", e))
}

async fn get_instance_info(
    instance_id: &str,
) -> Result<easytier::launcher::NetworkInstanceRunningInfo, String> {
    let id = parse_instance_id(instance_id)?;
    MANAGER
        .get_network_info(&id)
        .await
        .ok_or_else(|| "instance not found".to_string())
}

fn peer_conn_info_to_string(p: proto::api::instance::PeerConnInfo) -> String {
    format!(
        "my_peer_id: {}, dst_peer_id: {}, tunnel_info: {:?}",
        p.my_peer_id, p.peer_id, p.tunnel
    )
}

pub fn send_udp_to_localhost(message: &str) -> Result<(), String> {
    use std::net::UdpSocket;

    let socket = match UdpSocket::bind("0.0.0.0:0") {
        Ok(s) => s,
        Err(e) => return Err(format!("udp bind failed: {}", e)),
    };

    match socket.send_to(message.as_bytes(), "127.0.0.1:9999") {
        Ok(_) => Ok(()),
        Err(e) => Err(format!("udp send failed: {}", e)),
    }
}

pub fn handle_event(mut events: EventBusSubscriber) -> tokio::task::JoinHandle<()> {
    tokio::spawn(async move {
        loop {
            match events.recv().await {
                Ok(e) => match e {
                    GlobalCtxEvent::PeerAdded(p) => {
                        let msg = format!("peer added. peer_id: {}", p);
                        println!("{}", msg);
                        let _ = send_udp_to_localhost(&msg);
                    }
                    GlobalCtxEvent::PeerRemoved(p) => {
                        let msg = format!("peer removed. peer_id: {}", p);
                        println!("{}", msg);
                        let _ = send_udp_to_localhost(&msg);
                    }
                    GlobalCtxEvent::PeerConnAdded(p) => {
                        let conn_info = peer_conn_info_to_string(p);
                        let msg = format!("peer connection added. conn_info: {}", conn_info);
                        println!("{}", msg);
                        let _ = send_udp_to_localhost(&msg);
                    }
                    GlobalCtxEvent::PeerConnRemoved(p) => {
                        let msg = format!(
                            "peer connection removed. conn_info: {}",
                            peer_conn_info_to_string(p)
                        );
                        println!("{}", msg);
                        let _ = send_udp_to_localhost(&msg);
                    }
                    GlobalCtxEvent::ListenerAddFailed(p, msg) => {
                        let msg = format!("listener add failed. listener: {}, msg: {}", p, msg);
                        println!("{}", msg);
                        let _ = send_udp_to_localhost(&msg);
                    }
                    GlobalCtxEvent::ListenerAcceptFailed(p, msg) => {
                        let msg =
                            format!("listener accept failed. listener: {}, msg: {}", p, msg);
                        println!("{}", msg);
                        let _ = send_udp_to_localhost(&msg);
                    }
                    GlobalCtxEvent::ListenerAdded(p) => {
                        if p.scheme() == "ring" {
                            continue;
                        }
                        let msg = format!("listener added. listener: {}", p);
                        println!("{}", msg);
                        let _ = send_udp_to_localhost(&msg);
                    }
                    GlobalCtxEvent::ConnectionAccepted(local, remote) => {
                        let msg =
                            format!("connection accepted. local: {}, remote: {}", local, remote);
                        println!("{}", msg);
                        let _ = send_udp_to_localhost(&msg);
                    }
                    GlobalCtxEvent::ConnectionError(local, remote, err) => {
                        let msg = format!(
                            "connection error. local: {}, remote: {}, err: {}",
                            local, remote, err
                        );
                        println!("{}", msg);
                        let _ = send_udp_to_localhost(&msg);
                    }
                    GlobalCtxEvent::TunDeviceReady(dev) => {
                        let msg = format!("tun device ready. dev: {}", dev);
                        println!("{}", msg);
                        let _ = send_udp_to_localhost(&msg);
                    }
                    GlobalCtxEvent::TunDeviceError(err) => {
                        let msg = format!("tun device error. err: {}", err);
                        println!("{}", msg);
                        let _ = send_udp_to_localhost(&msg);
                    }
                    GlobalCtxEvent::Connecting(dst) => {
                        let msg = format!("connecting to peer. dst: {}", dst);
                        println!("{}", msg);
                        let _ = send_udp_to_localhost(&msg);
                    }
                    GlobalCtxEvent::ConnectError(dst, ip_version, err) => {
                        let msg = format!(
                            "connect error. dst: {}, ip_version: {}, err: {}",
                            dst, ip_version, err
                        );
                        println!("{}", msg);
                        let _ = send_udp_to_localhost(&msg);
                    }
                    GlobalCtxEvent::VpnPortalStarted(portal) => {
                        let msg = format!("vpn portal started. portal: {}", portal);
                        println!("{}", msg);
                        let _ = send_udp_to_localhost(&msg);
                    }
                    GlobalCtxEvent::VpnPortalClientConnected(portal, client_addr) => {
                        let msg = format!(
                            "vpn portal client connected. portal: {}, client_addr: {}",
                            portal, client_addr
                        );
                        println!("{}", msg);
                        let _ = send_udp_to_localhost(&msg);
                    }
                    GlobalCtxEvent::VpnPortalClientDisconnected(portal, client_addr) => {
                        let msg = format!(
                            "vpn portal client disconnected. portal: {}, client_addr: {}",
                            portal, client_addr
                        );
                        println!("{}", msg);
                        let _ = send_udp_to_localhost(&msg);
                    }
                    GlobalCtxEvent::DhcpIpv4Changed(old, new) => {
                        let msg = format!("dhcp ip changed. old: {:?}, new: {:?}", old, new);
                        println!("{}", msg);
                        let _ = send_udp_to_localhost(&msg);
                    }
                    GlobalCtxEvent::DhcpIpv4Conflicted(ip) => {
                        let msg = format!("dhcp ip conflict. ip: {:?}", ip);
                        println!("{}", msg);
                        let _ = send_udp_to_localhost(&msg);
                    }
                    GlobalCtxEvent::PortForwardAdded(cfg) => {
                        let msg = format!("port forward added. cfg: {:?}", cfg);
                        println!("{}", msg);
                        let _ = send_udp_to_localhost(&msg);
                    }
                    GlobalCtxEvent::ConfigPatched(_) => {}
                    GlobalCtxEvent::ProxyCidrsUpdated(_, _) => {}
                },
                Err(err) => {
                    eprintln!("event receive error: {:?}", err);
                    match err {
                        tokio::sync::broadcast::error::RecvError::Closed => {
                            let msg = "event channel closed; stop handling events";
                            println!("{}", msg);
                            let _ = send_udp_to_localhost(msg);
                            break;
                        }
                        tokio::sync::broadcast::error::RecvError::Lagged(n) => {
                            let msg = format!("event lagged, dropped {} events", n);
                            eprintln!("{}", msg);
                            let _ = send_udp_to_localhost(&msg);
                        }
                    }
                }
            }
        }
    })
}

pub fn easytier_version() -> Result<String, String> {
    Ok(easytier::VERSION.to_string())
}

pub async fn is_easytier_running(instance_id: String) -> bool {
    let Ok(id) = parse_instance_id(&instance_id) else {
        return false;
    };
    MANAGER.list_network_instance_ids().contains(&id)
}

pub struct NodeHopStats {
    pub peer_id: u32,
    pub target_ip: String,
    pub latency_ms: f64,
    pub packet_loss: f32,
    pub node_name: String,
}

pub struct KVNodeConnectionStats {
    pub conn_type: String,
    pub rx_bytes: u64,
    pub tx_bytes: u64,
    pub rx_packets: u64,
    pub tx_packets: u64,
}

pub struct KVNodeInfo {
    pub peer_id: u32,
    pub hostname: String,
    pub ipv4: String,
    pub latency_ms: f64,
    pub nat: String,
    pub hops: Vec<NodeHopStats>,
    pub loss_rate: f32,
    pub connections: Vec<KVNodeConnectionStats>,
    pub tunnel_proto: String,
    pub conn_type: String,
    pub rx_bytes: u64,
    pub tx_bytes: u64,
    pub version: String,
    pub cost: i32,
}

pub struct KVNetworkStatus {
    pub total_nodes: usize,
    pub nodes: Vec<KVNodeInfo>,
}

pub async fn get_ips(instance_id: String) -> Vec<String> {
    let info = match get_instance_info(&instance_id).await {
        Ok(info) => info,
        Err(_) => return Vec::new(),
    };

    let mut result = Vec::new();

    for route in &info.routes {
        if let Some(ipv4_addr) = &route.ipv4_addr {
            if let Some(addr) = &ipv4_addr.address {
                let ip = format!(
                    "{}.{}.{}.{}/{}",
                    (addr.addr >> 24) & 0xFF,
                    (addr.addr >> 16) & 0xFF,
                    (addr.addr >> 8) & 0xFF,
                    addr.addr & 0xFF,
                    ipv4_addr.network_length
                );
                if !result.contains(&ip) {
                    result.push(ip);
                }
            }
        }
    }

    result
}

pub async fn set_tun_fd(instance_id: String, fd: i32) -> Result<(), String> {
    let id = parse_instance_id(&instance_id)?;
    MANAGER
        .set_tun_fd(&id, fd)
        .map_err(|e| format!("set_tun_fd failed: {}", e))
}

pub async fn get_running_info(instance_id: String) -> String {
    let info = match get_instance_info(&instance_id).await {
        Ok(info) => info,
        Err(_) => return "null".to_string(),
    };

    serde_json::to_string(&json!({
        "dev_name": info.dev_name,
        "my_node_info": info.my_node_info.as_ref().map(|node| json!({
            "virtual_ipv4": node.virtual_ipv4.as_ref().map(|addr| json!({
                "address": addr.address.as_ref().map(|a| json!({ "addr": a.addr })),
            })),
        })),
        "routes": info.routes,
        "peer_route_pairs": info.peer_route_pairs,
    }))
    .unwrap_or_else(|_| "null".to_string())
}

pub struct FlagsC {
    pub default_protocol: String,
    pub dev_name: String,
    pub enable_encryption: bool,
    pub enable_ipv6: bool,
    pub mtu: u32,
    pub latency_first: bool,
    pub enable_exit_node: bool,
    pub no_tun: bool,
    pub use_smoltcp: bool,
    pub relay_network_whitelist: String,
    pub disable_p2p: bool,
    pub relay_all_peer_rpc: bool,
    pub disable_udp_hole_punching: bool,
    pub disable_tcp_hole_punching: bool,
    pub multi_thread: bool,
    pub data_compress_algo: i32,
    pub bind_device: bool,
    pub enable_kcp_proxy: bool,
    pub disable_kcp_input: bool,
    pub disable_relay_kcp: bool,
    pub proxy_forward_by_system: bool,
    pub accept_dns: bool,
    pub private_mode: bool,
    pub enable_quic_proxy: bool,
    pub disable_quic_input: bool,
    pub disable_sym_hole_punching: bool,
    pub tcp_whitelist: String,
    pub udp_whitelist: String,
}

pub struct Forward {
    pub bind_addr: String,
    pub dst_addr: String,
    pub proto: String,
}
pub fn create_server(config_toml: String, watch_event: bool) -> JoinHandle<Result<String, String>> {
    RT.spawn(async move {
        let cfg = TomlConfigLoader::new_from_str(&config_toml)
            .map_err(|e| format!("invalid config toml: {}", e))?;
        let instance_id = cfg.get_id();

        MANAGER
            .run_network_instance(cfg, watch_event, ConfigFileControl::STATIC_CONFIG)
            .map_err(|e| format!("start instance failed: {}", e))?;

        Ok(instance_id.to_string())
    })
}

pub fn create_server_with_flags(
    username: String,
    enable_dhcp: bool,
    specified_ip: String,
    room_name: String,
    room_password: String,
    severurl: Vec<String>,
    onurl: Vec<String>,
    cidrs: Vec<String>,
    forwards: Vec<Forward>,
    flag: FlagsC,
) -> JoinHandle<Result<String, String>> {
    RT.spawn(async move {
        let cfg = TomlConfigLoader::default();

        let mut listeners = Vec::new();
        for url in onurl {
            match url.parse() {
                Ok(parsed) => listeners.push(parsed),
                Err(e) => return Err(format!("invalid listener url: {}, error: {}", url, e)),
            }
        }
        cfg.set_listeners(listeners);

        cfg.set_hostname(Some(username));
        cfg.set_dhcp(enable_dhcp);
        for c in cidrs {
            cfg.add_proxy_cidr(c.parse().unwrap(), None);
        }
        let mut old = cfg.get_port_forwards();

        for c in forwards {
            let port_forward_item = PortForwardConfig {
                bind_addr: c.bind_addr.parse().unwrap(),
                dst_addr: c.dst_addr.parse().unwrap(),
                proto: c.proto,
            };
            old.push(port_forward_item);
        }

        cfg.set_port_forwards(old);
        let mut flags = cfg.get_flags();
        flags.default_protocol = flag.default_protocol;
        flags.dev_name = "astral".to_string();
        flags.enable_encryption = flag.enable_encryption;
        flags.enable_ipv6 = flag.enable_ipv6;
        flags.mtu = flag.mtu;
        flags.latency_first = flag.latency_first;
        flags.enable_exit_node = flag.enable_exit_node;
        flags.no_tun = flag.no_tun;
        flags.use_smoltcp = flag.use_smoltcp;
        flags.relay_network_whitelist = flag.relay_network_whitelist;
        flags.disable_p2p = flag.disable_p2p;
        flags.relay_all_peer_rpc = flag.relay_all_peer_rpc;
        flags.disable_udp_hole_punching = flag.disable_udp_hole_punching;
        flags.disable_tcp_hole_punching = flag.disable_tcp_hole_punching;
        flags.multi_thread = flag.multi_thread;
        flags.data_compress_algo = flag.data_compress_algo;
        flags.bind_device = flag.bind_device;
        flags.enable_kcp_proxy = flag.enable_kcp_proxy;
        flags.disable_kcp_input = flag.disable_kcp_input;
        flags.disable_relay_kcp = flag.disable_relay_kcp;
        flags.proxy_forward_by_system = flag.proxy_forward_by_system;
        flags.accept_dns = flag.accept_dns;
        flags.private_mode = flag.private_mode;
        flags.enable_quic_proxy = flag.enable_quic_proxy;
        flags.disable_quic_input = flag.disable_quic_input;
        flags.disable_sym_hole_punching = flag.disable_sym_hole_punching;
        cfg.set_flags(flags);

        if !flag.tcp_whitelist.is_empty() {
            let tcp_ports: Vec<String> = flag
                .tcp_whitelist
                .split(',')
                .map(|s| s.trim().to_string())
                .filter(|s| !s.is_empty())
                .collect();
            cfg.set_tcp_whitelist(tcp_ports);
        }
        if !flag.udp_whitelist.is_empty() {
            let udp_ports: Vec<String> = flag
                .udp_whitelist
                .split(',')
                .map(|s| s.trim().to_string())
                .filter(|s| !s.is_empty())
                .collect();
            cfg.set_udp_whitelist(udp_ports);
        }

        let mut peer_configs = Vec::new();
        for url in severurl {
            match url.parse() {
                Ok(uri) => peer_configs.push(PeerConfig { uri }),
                Err(e) => return Err(format!("invalid server url: {}, error: {}", url, e)),
            }
        }
        cfg.set_peers(peer_configs);

        if !enable_dhcp && !specified_ip.is_empty() {
            let ip_str = format!("{}/24", specified_ip);
            match ip_str.parse() {
                Ok(ip) => cfg.set_ipv4(Some(ip)),
                Err(e) => {
                    return Err(format!("invalid ip address: {}, error: {}", specified_ip, e))
                }
            }
        }

        cfg.set_network_identity(NetworkIdentity::new(room_name, room_password));
        let instance_id = cfg.get_id();

        MANAGER
            .run_network_instance(cfg, true, ConfigFileControl::STATIC_CONFIG)
            .map_err(|e| format!("start instance failed: {}", e))?;

        Ok(instance_id.to_string())
    })
}

pub fn close_server(instance_id: String) -> Result<(), String> {
    let id = parse_instance_id(&instance_id)?;
    MANAGER
        .delete_network_instance(vec![id])
        .map_err(|e| format!("delete instance failed: {}", e))?;
    Ok(())
}
pub async fn get_peer_route_pairs(instance_id: String) -> Result<Vec<PeerRoutePair>, String> {
    let info = get_instance_info(&instance_id).await?;

    let mut pairs = info.peer_route_pairs;

    if let Some(my_node_info) = &info.my_node_info {
        let my_peer_id = info
            .peers
            .iter()
            .find(|p| p.conns.iter().any(|c| !c.is_client))
            .map(|p| p.peer_id)
            .unwrap_or(0);

        let my_route = Route {
            peer_id: my_peer_id,
            ipv4_addr: my_node_info.virtual_ipv4.clone(),
            ipv6_addr: None,
            next_hop_peer_id: my_peer_id,
            cost: 0,
            path_latency: 0,
            proxy_cidrs: vec![],
            hostname: my_node_info.hostname.clone(),
            stun_info: my_node_info.stun_info.clone(),
            inst_id: "local".to_string(),
            version: my_node_info.version.clone(),
            feature_flag: None,
            next_hop_peer_id_latency_first: None,
            cost_latency_first: None,
            path_latency_latency_first: None,
        };

        let my_peer_info = info.peers.iter().find(|p| p.peer_id == my_peer_id).cloned();

        let my_pair = PeerRoutePair {
            route: Some(my_route),
            peer: my_peer_info,
        };

        pairs.push(my_pair);
    }

    Ok(pairs)
}

pub async fn get_network_status(instance_id: String) -> KVNetworkStatus {
    let pairs = get_peer_route_pairs(instance_id.clone()).await.unwrap_or_default();

    let running_info = get_instance_info(&instance_id).await.ok();
    let local_peer_id = running_info
        .as_ref()
        .and_then(|info| {
            info.peers
                .iter()
                .find(|p| p.conns.iter().any(|c| !c.is_client))
                .map(|p| p.peer_id)
        })
        .unwrap_or(0);

    let mut nodes = Vec::new();
    for pair in pairs.iter() {
        if let Some(route) = &pair.route {
            let cost = route.cost;
            let ipv4 = route
                .ipv4_addr
                .as_ref()
                .and_then(|addr| addr.address.as_ref())
                .map(|a| {
                    format!(
                        "{}.{}.{}.{}",
                        (a.addr >> 24) & 0xFF,
                        (a.addr >> 16) & 0xFF,
                        (a.addr >> 8) & 0xFF,
                        a.addr & 0xFF
                    )
                })
                .unwrap_or_else(|| "0.0.0.0".to_string());

            let mut node_info = KVNodeInfo {
                peer_id: route.peer_id,
                hostname: route.hostname.clone(),
                hops: {
                    fn collect_hops(
                        pairs: &[PeerRoutePair],
                        current_peer_id: u32,
                        mut path: Vec<NodeHopStats>,
                        visited: &mut std::collections::HashSet<u32>,
                    ) -> Vec<NodeHopStats> {
                        if visited.contains(&current_peer_id) {
                            return path;
                        }
                        visited.insert(current_peer_id);

                        if let Some(pair) = pairs.iter().find(|p| {
                            p.route
                                .as_ref()
                                .map_or(false, |r| r.peer_id == current_peer_id)
                        }) {
                            if let Some(route) = &pair.route {
                                let ip = route
                                    .ipv4_addr
                                    .as_ref()
                                    .and_then(|addr| addr.address.as_ref())
                                    .map(|a| {
                                        format!(
                                            "{}.{}.{}.{}",
                                            (a.addr >> 24) & 0xFF,
                                            (a.addr >> 16) & 0xFF,
                                            (a.addr >> 8) & 0xFF,
                                            a.addr & 0xFF
                                        )
                                    })
                                    .unwrap_or_default();

                                let (latency, loss) = pair.peer.as_ref().map_or((0.0, 0.0), |p| {
                                    let min_latency = p
                                        .conns
                                        .iter()
                                        .filter_map(|c| c.stats.as_ref().map(|s| s.latency_us))
                                        .min()
                                        .unwrap_or(0) as f64
                                        / 1000.0;

                                    let avg_loss = p.conns.iter().map(|c| c.loss_rate).sum::<f32>()
                                        / p.conns.len().max(1) as f32;

                                    (min_latency, avg_loss as f64)
                                });

                                path.push(NodeHopStats {
                                    peer_id: current_peer_id,
                                    target_ip: ip,
                                    latency_ms: latency,
                                    packet_loss: loss as f32,
                                    node_name: route.hostname.clone(),
                                });

                                if route.next_hop_peer_id != current_peer_id
                                    && route.next_hop_peer_id != 0
                                {
                                    return collect_hops(
                                        pairs,
                                        route.next_hop_peer_id,
                                        path,
                                        visited,
                                    );
                                }
                            }
                        }
                        path
                    }

                    let mut hops = Vec::new();
                    if let Some(route) = &pair.route {
                        let mut visited = std::collections::HashSet::new();
                        let target_ip = route
                            .ipv4_addr
                            .as_ref()
                            .and_then(|addr| addr.address.as_ref())
                            .map(|a| {
                                format!(
                                    "{}.{}.{}.{}",
                                    (a.addr >> 24) & 0xFF,
                                    (a.addr >> 16) & 0xFF,
                                    (a.addr >> 8) & 0xFF,
                                    a.addr & 0xFF
                                )
                            })
                            .unwrap_or_default();

                        if let Some(info) = &running_info {
                            if let Some(local_node) = &info.my_node_info {
                                hops.push(NodeHopStats {
                                    peer_id: local_peer_id,
                                    target_ip: local_node
                                        .virtual_ipv4
                                        .as_ref()
                                        .and_then(|addr| addr.address.as_ref())
                                        .map(|a| {
                                            format!(
                                                "{}.{}.{}.{}",
                                                (a.addr >> 24) & 0xFF,
                                                (a.addr >> 16) & 0xFF,
                                                (a.addr >> 8) & 0xFF,
                                                a.addr & 0xFF
                                            )
                                        })
                                        .unwrap_or_else(|| local_node.hostname.clone()),
                                    latency_ms: 0.0,
                                    packet_loss: 0.0,
                                    node_name: local_node.hostname.clone(),
                                });

                                if let Some(local_route) =
                                    info.routes.iter().find(|r| r.peer_id == route.peer_id)
                                {
                                    let mut next_hops = collect_hops(
                                        pairs.as_slice(),
                                        local_route.next_hop_peer_id,
                                        Vec::new(),
                                        &mut visited,
                                    );
                                    hops.append(&mut next_hops);

                                    let last_node_is_target = hops
                                        .last()
                                        .map_or(false, |last| last.target_ip == target_ip);

                                    if !last_node_is_target && !visited.contains(&route.peer_id) {
                                        let (latency, loss) =
                                            pair.peer.as_ref().map_or((0.0, 0.0), |p| {
                                                let min_latency = p
                                                    .conns
                                                    .iter()
                                                    .filter_map(|c| {
                                                        c.stats
                                                            .as_ref()
                                                            .map(|s| s.latency_us)
                                                    })
                                                    .min()
                                                    .unwrap_or(0) as f64
                                                    / 1000.0;

                                                let avg_loss = p
                                                    .conns
                                                    .iter()
                                                    .map(|c| c.loss_rate)
                                                    .sum::<f32>()
                                                    / p.conns.len().max(1) as f32;

                                                (min_latency, avg_loss as f64)
                                            });

                                        hops.push(NodeHopStats {
                                            peer_id: route.peer_id,
                                            target_ip: target_ip.clone(),
                                            latency_ms: latency,
                                            packet_loss: loss as f32,
                                            node_name: route.hostname.clone(),
                                        });
                                    }
                                }
                            }
                        }

                        if hops.len() <= 1 {
                            if !hops.iter().any(|h| h.target_ip == target_ip) {
                                let (latency, loss) = pair.peer.as_ref().map_or((0.0, 0.0), |p| {
                                    let min_latency = p
                                        .conns
                                        .iter()
                                        .filter_map(|c| c.stats.as_ref().map(|s| s.latency_us))
                                        .min()
                                        .unwrap_or(0) as f64
                                        / 1000.0;

                                    let avg_loss = p.conns.iter().map(|c| c.loss_rate).sum::<f32>()
                                        / p.conns.len().max(1) as f32;

                                    (min_latency, avg_loss as f64)
                                });

                                hops.push(NodeHopStats {
                                    peer_id: route.peer_id,
                                    target_ip: target_ip,
                                    latency_ms: latency,
                                    packet_loss: loss as f32,
                                    node_name: route.hostname.clone(),
                                });
                            }
                        }
                    }
                    hops
                },
                latency_ms: if route.cost == 1 {
                    pair.get_latency_ms().unwrap_or(0.0)
                } else {
                    route.path_latency_latency_first() as f64
                },
                ipv4,
                loss_rate: if let Some(peer) = &pair.peer {
                    let mut total_loss_rate = 0.0;
                    for conn in &peer.conns {
                        total_loss_rate += conn.loss_rate;
                    }
                    total_loss_rate
                } else {
                    0.0
                },
                nat: route.stun_info.as_ref().map_or_else(
                    || "Unknown".to_string(),
                    |stun| {
                        let nat_type =
                            NatType::try_from(stun.udp_nat_type).unwrap_or(NatType::Unknown);
                        format!("{:?}", nat_type)
                    },
                ),
                connections: Vec::new(),
                version: route.version.clone(),
                cost,
                conn_type: pair.get_udp_nat_type(),
                tunnel_proto: pair
                    .get_conn_protos()
                    .unwrap_or_default()
                    .join(",")
                    .to_string(),
                rx_bytes: pair.get_rx_bytes().unwrap_or_default(),
                tx_bytes: pair.get_tx_bytes().unwrap_or_default(),
            };

            if let Some(peer) = &pair.peer {
                for conn in &peer.conns {
                    if let Some(stats) = &conn.stats {
                        let conn_type = if let Some(tunnel) = &conn.tunnel {
                            tunnel.tunnel_type.clone()
                        } else {
                            "unknown".to_string()
                        };

                        node_info.connections.push(KVNodeConnectionStats {
                            conn_type,
                            rx_bytes: stats.rx_bytes,
                            tx_bytes: stats.tx_bytes,
                            rx_packets: stats.rx_packets,
                            tx_packets: stats.tx_packets,
                        });
                    }
                }
            }

            nodes.push(node_info);
        }
    }

    KVNetworkStatus {
        total_nodes: nodes.len(),
        nodes,
    }
}

pub fn init_app() {
    lazy_static::initialize(&RT);
}
