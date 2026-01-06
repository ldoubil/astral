use easytier::common::config::{ConfigFileControl, PortForwardConfig};
pub use easytier::{
    common::{
        self,
        config::{ConfigLoader, NetworkIdentity, PeerConfig, TomlConfigLoader},
        global_ctx::{EventBusSubscriber, GlobalCtxEvent},
    },
    launcher::NetworkInstance,
    proto,
    proto::{
        api::{
            instance::{
                list_peer_route_pair, PeerRoutePair, Route,
            },
            manage::MyNodeInfo,
        },
        common::NatType,
    },
    utils::cost_to_str,
};
use lazy_static::lazy_static;
use serde_json::json;
pub use std::collections::BTreeMap;
use std::sync::Arc;
use tokio::sync::RwLock;
use tokio::runtime::Runtime;
pub use tokio::task::JoinHandle;

pub static DEFAULT_ET_DNS_ZONE: &str = "as.net.";

lazy_static! {
    static ref INSTANCE: Arc<RwLock<Option<NetworkInstance>>> = Arc::new(RwLock::new(None));
}
// 创建一个 NetworkInstance 类型变量 储存当前服务器
lazy_static! {
    static ref RT: Runtime = Runtime::new().expect("创建 Tokio 运行时失败");
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
        Err(e) => return Err(format!("绑定UDP套接字失败: {}", e)),
    };

    match socket.send_to(message.as_bytes(), "127.0.0.1:9999") {
        Ok(_) => Ok(()),
        Err(e) => Err(format!("发送UDP数据失败: {}", e)),
    }
}

pub fn handle_event(mut events: EventBusSubscriber) -> tokio::task::JoinHandle<()> {
    tokio::spawn(async move {
        loop {
            match events.recv().await {
                Ok(e) => {
                    //  println!("Received event: {:?}", e);
                    match e {
                        GlobalCtxEvent::PeerAdded(p) => {
                            println!("{}", format!("新节点已添加。节点ID: {}", p));
                            let _ = send_udp_to_localhost(&format!("新节点已添加。节点ID: {}", p));
                        }
                        GlobalCtxEvent::PeerRemoved(p) => {
                            println!("{}", format!("节点已移除。节点ID: {}", p));
                            let _ = send_udp_to_localhost(&format!("节点已移除。节点ID: {}", p));
                        }
                        GlobalCtxEvent::PeerConnAdded(p) => {
                            let conn_info = peer_conn_info_to_string(p);
                            let msg = format!("新节点连接已添加。连接信息: {}", conn_info);
                            println!("{}", msg);
                            let _ = send_udp_to_localhost(&msg);
                        }
                        GlobalCtxEvent::PeerConnRemoved(p) => {
                            let msg = format!(
                                "节点连接已移除。连接信息: {}",
                                peer_conn_info_to_string(p)
                            );
                            println!("{}", msg);
                            let _ = send_udp_to_localhost(&msg);
                        }
                        GlobalCtxEvent::ListenerAddFailed(p, msg) => {
                            let msg = format!("监听器添加失败。监听器: {}, 消息: {}", p, msg);
                            println!("{}", msg);
                            let _ = send_udp_to_localhost(&msg);
                        }
                        GlobalCtxEvent::ListenerAcceptFailed(p, msg) => {
                            let msg = format!("监听器接受失败。监听器: {}, 消息: {}", p, msg);
                            println!("{}", msg);
                            let _ = send_udp_to_localhost(&msg);
                        }
                        GlobalCtxEvent::ListenerAdded(p) => {
                            if p.scheme() == "ring" {
                                continue;
                            }
                            let msg = format!("新监听器已添加。监听器: {}", p);
                            println!("{}", msg);
                            let _ = send_udp_to_localhost(&msg);
                        }
                        GlobalCtxEvent::ConnectionAccepted(local, remote) => {
                            let msg = format!("新连接已接受。本地: {}, 远程: {}", local, remote);
                            println!("{}", msg);
                            let _ = send_udp_to_localhost(&msg);
                        }
                        GlobalCtxEvent::ConnectionError(local, remote, err) => {
                            let msg = format!(
                                "连接错误。本地: {}, 远程: {}, 错误: {}",
                                local, remote, err
                            );
                            println!("{}", msg);
                            let _ = send_udp_to_localhost(&msg);
                        }
                        GlobalCtxEvent::TunDeviceReady(dev) => {
                            let msg = format!("TUN 设备就绪。设备: {}", dev);
                            println!("{}", msg);
                            let _ = send_udp_to_localhost(&msg);
                        }
                        GlobalCtxEvent::TunDeviceError(err) => {
                            let msg = format!("TUN 设备错误。错误: {}", err);
                            println!("{}", msg);
                            let _ = send_udp_to_localhost(&msg);
                        }
                        GlobalCtxEvent::Connecting(dst) => {
                            let msg = format!("正在连接到节点。目标: {}", dst);
                            println!("{}", msg);
                            let _ = send_udp_to_localhost(&msg);
                        }
                        GlobalCtxEvent::ConnectError(dst, ip_version, err) => {
                            let msg = format!(
                                "连接到节点错误。目标: {}, IP版本: {}, 错误: {}",
                                dst, ip_version, err
                            );
                            println!("{}", msg);
                            let _ = send_udp_to_localhost(&msg);
                        }
                        GlobalCtxEvent::VpnPortalStarted(portal) => {
                            let msg = format!("VPN 门户已启动。门户: {}", portal);
                            println!("{}", msg);
                            let _ = send_udp_to_localhost(&msg);
                        }
                        GlobalCtxEvent::VpnPortalClientConnected(portal, client_addr) => {
                            let msg = format!(
                                "VPN 门户客户端已连接。门户: {}, 客户端地址: {}",
                                portal, client_addr
                            );
                            println!("{}", msg);
                            let _ = send_udp_to_localhost(&msg);
                        }
                        GlobalCtxEvent::VpnPortalClientDisconnected(portal, client_addr) => {
                            let msg = format!(
                                "VPN 门户客户端已断开连接。门户: {}, 客户端地址: {}",
                                portal, client_addr
                            );
                            println!("{}", msg);
                            let _ = send_udp_to_localhost(&msg);
                        }
                        GlobalCtxEvent::DhcpIpv4Changed(old, new) => {
                            let msg = format!("DHCP IP 已更改。旧: {:?}, 新: {:?}", old, new);
                            println!("{}", msg);
                            let _ = send_udp_to_localhost(&msg);
                        }
                        GlobalCtxEvent::DhcpIpv4Conflicted(ip) => {
                            let msg = format!("DHCP IP 冲突。IP: {:?}", ip);
                            println!("{}", msg);
                            let _ = send_udp_to_localhost(&msg);
                        }
                        GlobalCtxEvent::PortForwardAdded(port_forward_config_pb) => {
                            let msg = format!("端口转发已添加。配置: {:?}", port_forward_config_pb);
                            println!("{}", msg);
                            let _ = send_udp_to_localhost(&msg);
                        }
                        GlobalCtxEvent::ConfigPatched(_instance_config_patch) => todo!(),
                        GlobalCtxEvent::ProxyCidrsUpdated(_ipv4_cidrs, _ipv4_cidrs1) => todo!(),
                    }
                }
                Err(err) => {
                    eprintln!("接收事件错误: {:?}", err);
                    // 根据错误类型决定是否中断循环
                    match err {
                        tokio::sync::broadcast::error::RecvError::Closed => {
                            let msg = "事件通道已关闭，停止事件处理。";
                            println!("{}", msg);
                            let _ = send_udp_to_localhost(msg);
                            break; // Exit the loop if the channel is closed
                        }
                        tokio::sync::broadcast::error::RecvError::Lagged(n) => {
                            let msg = format!("事件处理滞后，丢失了 {} 个事件。", n);
                            eprintln!("{}", msg);
                            let _ = send_udp_to_localhost(&msg);
                            // Decide if lagging is critical enough to break or just log
                        }
                    }
                }
            }
        }
    })
}

async fn create_and_store_network_instance(cfg: TomlConfigLoader) -> Result<(), String> {
    println!("{:?}", cfg);

    // 在移动 cfg 之前先获取 ID
    let name = cfg.get_id().to_string();
    // 创建网络实例
    let mut network = NetworkInstance::new(cfg, ConfigFileControl::STATIC_CONFIG);
    // 启动网络实例，并处理可能的错误
    handle_event(network.start().unwrap());
    println!("instance {} started", name);
    // 将实例存储到 INSTANCE 中
    let mut instance_guard = INSTANCE
        .write()
        .await;
    if instance_guard.is_none() {
        *instance_guard = Some(network);
        println!("实例已成功储存");
    } else {
        println!("网络实例已存在");
    }
    print!("成功储存");

    Ok(())
}

// 返回EasyTier的版本号
pub fn easytier_version() -> Result<String, String> {
    Ok(easytier::VERSION.to_string())
}

// 是否在运行
pub async fn is_easytier_running() -> bool {
    let instance = INSTANCE.read().await;
    instance.is_some()
}
// 定义节点跳跃统计信息结构体
pub struct NodeHopStats {
    pub target_ip: String, // 目标节点IP
    pub latency_ms: f64,   // 延迟(毫秒)
    pub packet_loss: f32,  // 丢包率
    pub node_name: String, // 节点名称
}

// 定义节点连接统计信息结构体
pub struct KVNodeConnectionStats {
    pub conn_type: String, // 连接类型
    pub rx_bytes: u64,
    pub tx_bytes: u64,
    pub rx_packets: u64,
    pub tx_packets: u64,
}
// 定义节点信息结构体
pub struct KVNodeInfo {
    pub hostname: String,
    pub ipv4: String,
    pub latency_ms: f64,
    pub nat: String, // NAT类型
    // NodeHopStats 列表 从近到远
    pub hops: Vec<NodeHopStats>,
    pub loss_rate: f32,
    pub connections: Vec<KVNodeConnectionStats>,

    pub tunnel_proto: String,
    pub conn_type: String, // 连接类型
    pub rx_bytes: u64,
    pub tx_bytes: u64,

    pub version: String,
    pub cost: i32,
}
// 定义节点网络状态结构体
pub struct KVNetworkStatus {
    pub total_nodes: usize,
    pub nodes: Vec<KVNodeInfo>,
}

// 获取网络中所有节点的IP地址列表
pub async fn get_ips() -> Vec<String> {
    let mut result = Vec::new();

    // Lock the mutex and access the instance if it exists
    let instance = INSTANCE.read().await;

    if let Some(instance) = instance.as_ref() {
            if let Ok(info) = instance.get_running_info().await {
            // Add all remote node IPs
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
                        // Avoid duplicates
                        if !result.contains(&ip) {
                            result.push(ip);
                        }
                    }
                }
            }
        }
    }

    result
}

// 设置TUN设备的文件描述符
pub async fn set_tun_fd(fd: i32) -> Result<(), String> {
    let mut instance = INSTANCE.write().await;
    if let Some(instance) = instance.as_mut() {
        instance.set_tun_fd(fd);
        Ok(())
    } else {
        Err("No instance available".to_string())
    }
}

pub async fn get_running_info() -> String {
    let instance = INSTANCE.read().await;
    
    if let Some(instance) = instance.as_ref() {
        if let Ok(info) = instance.get_running_info().await {
            return serde_json::to_string(&json!({
                "dev_name": info.dev_name,
                "my_node_info": info.my_node_info.as_ref().map(|node| json!({
                    "virtual_ipv4": node.virtual_ipv4.as_ref().map(|addr| json!({
                        "address": addr.address.as_ref().map(|a| json!({ "addr": a.addr })),
                    })),
                })),
                "routes": info.routes,
                "peer_route_pairs": info.peer_route_pairs,
            })).unwrap_or_else(|_| "null".to_string());
        }
    }
    "null".to_string()
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

// 创建服务器
pub fn create_server(
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
) -> JoinHandle<Result<(), String>> {
    print!("{}", format!("创建服务器: {}，启用DHCP: {}, 指定IP: {}, 房间名称: {}, 房间密码: {}, 服务器URL: {:?}, 监听器URL: {:?}", username, enable_dhcp, specified_ip, room_name, room_password, severurl, onurl));
    RT.spawn(async move {
        // Create config with better error handling
        let cfg = TomlConfigLoader::default();

        // Set listeners with proper error handling
        let mut listeners = Vec::new();
        for url in onurl {
            match url.parse() {
                Ok(parsed) => listeners.push(parsed),
                Err(e) => return Err(format!("Invalid listener URL: {}, error: {}", url, e)),
            }
        }
        cfg.set_listeners(listeners);

        // Set hostname and other settings
        cfg.set_hostname(Some(username));
        cfg.set_dhcp(enable_dhcp);
        for c in cidrs {
            cfg.add_proxy_cidr(c.parse().unwrap(), None);
        }
        let mut old = cfg.get_port_forwards();

        for c in forwards {
            // 打印
            println!(
                "{}",
                format!(
                    "添加端口转发: {} -> {} -{}",
                    c.bind_addr, c.dst_addr, c.proto
                )
            );
            let port_forward_item = PortForwardConfig {
                bind_addr: c.bind_addr.parse().unwrap(),
                dst_addr: c.dst_addr.parse().unwrap(),
                proto: c.proto,
            };
            old.push(port_forward_item);
        }

        cfg.set_port_forwards(old);
        // Set flags more efficiently by directly mapping from input
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

        // Set port whitelists
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

        // Configure peer connections with proper error handling
        let mut peer_configs = Vec::new();
        for url in severurl {
            match url.parse() {
                Ok(uri) => peer_configs.push(PeerConfig { uri }),
                Err(e) => return Err(format!("Invalid server URL: {}, error: {}", url, e)),
            }
        }
        cfg.set_peers(peer_configs);

        // Set IP if DHCP is disabled
        if !enable_dhcp && !specified_ip.is_empty() {
            let ip_str = format!("{}/24", specified_ip);
            match ip_str.parse() {
                Ok(ip) => cfg.set_ipv4(Some(ip)),
                Err(e) => {
                    return Err(format!(
                        "Invalid IP address: {}, error: {}",
                        specified_ip, e
                    ))
                }
            }
        }

        // Set network identity
        cfg.set_network_identity(NetworkIdentity::new(room_name, room_password));

        // 直接启动网络实例，无需嵌套 spawn
        create_and_store_network_instance(cfg).await
    })
}

// 关闭服务器实例
pub fn close_server() {
    RT.spawn(async {
        // 获取mutex锁
        let mut locked_instance = INSTANCE.write().await;

        println!(
            "关闭前实例状态: {}",
            if locked_instance.is_some() {
                "存在"
            } else {
                "不存在"
            }
        ); // 添加关闭前日志

        // 如果实例存在，则丢弃它
        if let Some(instance) = locked_instance.take() {
            println!("正在关闭实例");
            // 丢弃实例
            drop(instance);
            println!("实例已成功关闭");
        } else {
            println!("没有找到需要关闭的实例");
        }

        println!(
            "关闭后实例状态: {}",
            if locked_instance.is_some() {
                "存在"
            } else {
                "不存在"
            }
        ); // 添加关闭后日志
    });
}

// 创建一个网卡跃点数据结构
// 网卡跃点数据结构

pub async fn get_peer_route_pairs() -> Result<Vec<PeerRoutePair>, String> {
    let instance_guard = INSTANCE.read().await;

    if let Some(instance) = instance_guard.as_ref() {
        // 获取运行信息
        match instance.get_running_info().await {
            Ok(info) => {
            let mut pairs = info.peer_route_pairs;
            // 如果存在本地节点信息，添加到结果中
            if let Some(my_node_info) = &info.my_node_info {
                // 获取本地节点ID
                // 注意：这里的逻辑可能需要根据单例模式调整，假设本地节点信息可以直接从 info 中获取
                // 使用原始逻辑查找本地 peer_id
                let my_peer_id = info
                    .peers
                    .iter()
                    .find(|p| p.conns.iter().any(|c| !c.is_client))
                    .map(|p| p.peer_id)
                    .unwrap_or(0);

                // 创建一个表示本地节点的Route
                let my_route = proto::api::instance::Route {
                    peer_id: my_peer_id,
                    ipv4_addr: my_node_info.virtual_ipv4.clone(),
                    ipv6_addr: None, // 添加ipv6地址字段,目前暂不支持ipv6
                    next_hop_peer_id: my_peer_id, // 指向自己
                    cost: 0,                      // 到自己的成本为0
                    path_latency: 0,              // 到自己的延迟为0
                    proxy_cidrs: vec![],
                    hostname: my_node_info.hostname.clone(),
                    stun_info: my_node_info.stun_info.clone(),
                    inst_id: "local".to_string(), // 标记为本地实例
                    version: my_node_info.version.clone(),
                    feature_flag: None, // 本地节点通常没有特性标志
                    next_hop_peer_id_latency_first: None,
                    cost_latency_first: None,
                    path_latency_latency_first: None,
                };

                // 创建一个表示本地节点的PeerInfo，包含网络统计信息
                // 注意：本地节点的PeerInfo可能需要特殊处理或从其他地方获取
                let my_peer_info = info.peers.iter().find(|p| p.peer_id == my_peer_id).cloned();

                // 创建一个表示本地节点的PeerRoutePair
                let my_pair = proto::api::instance::PeerRoutePair {
                    route: Some(my_route),
                    peer: my_peer_info, // 使用找到的PeerInfo或None
                };

                // 添加到结果中
                pairs.push(my_pair);
            }

            return Ok(pairs);
        }
        Err(_) => Err("无法获取运行信息".to_string())
        }
    } else {
        Err("没有运行中的网络实例".to_string())
    }
}

// 获取网络状态信息
pub async fn get_network_status() -> KVNetworkStatus {
    let pairs = get_peer_route_pairs().await.unwrap_or_default();
    
    // 提前获取运行信息
    let instance_guard = INSTANCE.read().await;
    let running_info = if let Some(instance) = instance_guard.as_ref() {
        instance.get_running_info().await.ok()
    } else {
        None
    };
    
    let mut nodes = Vec::new();
    for pair in pairs.iter() {
        if let Some(route) = &pair.route {
            let cost = route.cost;
            // 使用 get_running_info 中的逻辑来获取IPv4地址
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
                hostname: route.hostname.clone(),

                hops: {
                    // 新建递归函数收集完整路径
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

                        // 查找当前节点的信息
                        if let Some(pair) = pairs.iter().find(|p| {
                            p.route
                                .as_ref()
                                .map_or(false, |r| r.peer_id == current_peer_id)
                        }) {
                            if let Some(route) = &pair.route {
                                // 获取IP地址
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

                                // 计算延迟和丢包率
                                let (latency, loss) = pair.peer.as_ref().map_or((0.0, 0.0), |p| {
                                    let min_latency = p
                                        .conns
                                        .iter()
                                        .filter_map(|c| c.stats.as_ref().map(|s| s.latency_us))
                                        .min()
                                        .unwrap_or(0)
                                        as f64
                                        / 1000.0;

                                    let avg_loss = p.conns.iter().map(|c| c.loss_rate).sum::<f32>()
                                        / p.conns.len().max(1) as f32;

                                    (min_latency, avg_loss as f64)
                                });

                                // 添加当前节点到路径
                                path.push(NodeHopStats {
                                    target_ip: ip,
                                    latency_ms: latency,
                                    packet_loss: loss as f32,
                                    node_name: route.hostname.clone(),
                                });

                                // 如果下一跳不是自己，继续递归
                                if route.next_hop_peer_id != current_peer_id
                                    && route.next_hop_peer_id != 0
                                {
                                    // 查找下一跳节点
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

                    // 使用路由表中的next_hop_peer_id构建完整路径
                    let mut hops = Vec::new();
                    if let Some(route) = &pair.route {
                        let mut visited = std::collections::HashSet::new();

                        // 从当前节点开始，收集到目标节点的完整路径
                        // 先添加本地节点信息
                        if let Some(info) = &running_info {
                            if let Some(local_node) = &info.my_node_info {
                                    // 添加本地节点作为起点
                                    hops.push(NodeHopStats {
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

                                    // 查找从本地到目标节点的路由
                                    if let Some(local_route) =
                                        info.routes.iter().find(|r| r.peer_id == route.peer_id)
                                    {
                                        // 收集中间节点
                                        let mut next_hops = collect_hops(
                                            pairs.as_slice(),
                                            local_route.next_hop_peer_id,
                                            Vec::new(),
                                            &mut visited,
                                        );
                                        hops.append(&mut next_hops);

                                        // 确保目标节点被添加到路径中
                                        // 检查最后一个节点是否是目标节点
                                        let last_node_is_target =
                                            hops.last().map_or(false, |last| {
                                                // 比较 hostname
                                                last.node_name == route.hostname
                                            });

                                        // 如果最后一个节点不是目标节点，则添加目标节点
                                        if !last_node_is_target && !visited.contains(&route.peer_id)
                                        {
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

                                            let (latency, loss) =
                                                pair.peer.as_ref().map_or((0.0, 0.0), |p| {
                                                    let min_latency = p
                                                        .conns
                                                        .iter()
                                                        .filter_map(|c| {
                                                            c.stats.as_ref().map(|s| s.latency_us)
                                                        })
                                                        .min()
                                                        .unwrap_or(0)
                                                        as f64
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
                                                target_ip: ip,
                                                latency_ms: latency,
                                                packet_loss: loss as f32,
                                                node_name: route.hostname.clone(),
                                            });
                                        }
                                    }
                                }
                            }

                        // 如果没有收集到任何跳点（可能是直连节点），则直接添加目标节点
                        // 检查 hops 是否只包含本地节点
                        if hops.len() <= 1 {
                            // 确保目标节点不在hops中（避免重复添加）
                            if !hops.iter().any(|h| h.node_name == route.hostname) {
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
                                        .unwrap_or(0)
                                        as f64
                                        / 1000.0;

                                    let avg_loss = p.conns.iter().map(|c| c.loss_rate).sum::<f32>()
                                        / p.conns.len().max(1) as f32;

                                    (min_latency, avg_loss as f64)
                                });

                                hops.push(NodeHopStats {
                                    target_ip: ip,
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
                ipv4: ipv4,

                loss_rate: if let Some(peer) = &pair.peer {
                    let mut total_loss_rate = 0.0;
                    for conn in &peer.conns {
                        total_loss_rate += conn.loss_rate;
                    }
                    total_loss_rate
                } else {
                    0.0 // 如果没有连接信息，默认为0
                },
                nat: route.stun_info.as_ref().map_or_else(
                    || "Unknown".to_string(),
                    |stun| {
                        // 使用NatType枚举替代直接匹配数字
                        let nat_type =
                            NatType::try_from(stun.udp_nat_type).unwrap_or(NatType::Unknown);
                        // println!("udp{:?}", NatType::try_from(stun.udp_nat_type).unwrap_or(NatType::Unknown));
                        // println!("tcp{:?}", NatType::try_from(stun.tcp_nat_type).unwrap_or(NatType::Unknown));
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

            // 收集连接统计信息
            if let Some(peer) = &pair.peer {
                for conn in &peer.conns {
                    if let Some(stats) = &conn.stats {
                        let conn_type = if let Some(tunnel) = &conn.tunnel {
                            tunnel.tunnel_type.clone()
                        } else {
                            "未知".to_string()
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
