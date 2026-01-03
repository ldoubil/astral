//! 魔法墙 (Magic Wall) - WFP 防火墙管理模块
//! 
//! 简化版实现，提供基本的防火墙规则管理接口

use serde::{Deserialize, Serialize};

#[cfg(target_os = "windows")]
use std::collections::HashMap;
#[cfg(target_os = "windows")]
use std::sync::Mutex;

// ============= 公共数据结构 =============

/// 魔法墙规则配置
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MagicWallRule {
    pub id: String,
    pub name: String,
    pub enabled: bool,
    pub action: String,           // "allow" or "block"
    pub protocol: String,          // "tcp", "udp", "both", "any"
    pub direction: String,         // "inbound", "outbound", "both"
    pub app_path: Option<String>,
    pub remote_ip: Option<String>,
    pub local_ip: Option<String>,
    pub remote_port: Option<String>,
    pub local_port: Option<String>,
    pub description: Option<String>,
    pub created_at: Option<i64>,
}

/// 魔法墙状态
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MagicWallStatus {
    pub is_running: bool,
    pub active_rules: usize,
    pub total_rules: usize,
}

// ============= Windows 实现 =============

#[cfg(target_os = "windows")]
mod wfp_impl {
    use super::*;
    use anyhow::{bail, Result};
    use ipnetwork::IpNetwork;
    use std::net::IpAddr;
    use std::str::FromStr;
    use windows::core::{PCWSTR, PWSTR};
    use windows::Win32::Foundation::HANDLE;
    use windows::Win32::NetworkManagement::WindowsFilteringPlatform::*;
    use windows::Win32::System::Rpc::RPC_C_AUTHN_DEFAULT;

    #[derive(Debug, Clone)]
    pub struct FilterRule {
        pub name: String,
        pub action: RuleAction,
        pub protocol: Protocol,
        pub direction: Direction,
        pub application: Option<String>,
        pub remote_ip: Option<IpFilter>,
        pub local_ip: Option<IpFilter>,
        pub remote_port: Option<PortFilter>,
        pub local_port: Option<PortFilter>,
    }

    impl FilterRule {
        pub fn new(name: impl Into<String>, action: RuleAction) -> Self {
            Self {
                name: name.into(),
                action,
                protocol: Protocol::Both,
                direction: Direction::Both,
                application: None,
                remote_ip: None,
                local_ip: None,
                remote_port: None,
                local_port: None,
            }
        }

        pub fn protocol(mut self, protocol: Protocol) -> Self {
            self.protocol = protocol;
            self
        }

        pub fn direction(mut self, direction: Direction) -> Self {
            self.direction = direction;
            self
        }

        pub fn application(mut self, path: impl Into<String>) -> Self {
            self.application = Some(path.into());
            self
        }

        pub fn remote_ip(mut self, ip: IpFilter) -> Self {
            self.remote_ip = Some(ip);
            self
        }

        pub fn local_ip(mut self, ip: IpFilter) -> Self {
            self.local_ip = Some(ip);
            self
        }

        pub fn remote_port(mut self, port: PortFilter) -> Self {
            self.remote_port = Some(port);
            self
        }

        pub fn local_port(mut self, port: PortFilter) -> Self {
            self.local_port = Some(port);
            self
        }
    }

    #[derive(Debug, Clone, Copy, PartialEq, Eq)]
    pub enum RuleAction {
        Allow,
        Block,
    }

    #[derive(Debug, Clone, Copy, PartialEq, Eq)]
    pub enum Protocol {
        TCP,
        UDP,
        Both,
        Any,
    }

    #[derive(Debug, Clone, Copy, PartialEq, Eq)]
    pub enum Direction {
        Inbound,
        Outbound,
        Both,
    }

    #[derive(Debug, Clone)]
    pub enum IpFilter {
        Single(IpAddr),
        Network(IpNetwork),
    }

    impl IpFilter {
        pub fn single(addr: IpAddr) -> Self {
            IpFilter::Single(addr)
        }

        pub fn network(network: IpNetwork) -> Self {
            IpFilter::Network(network)
        }
    }

    #[derive(Debug, Clone)]
    pub enum PortFilter {
        Single(u16),
        Range(u16, u16),
    }

    impl PortFilter {
        pub fn single(port: u16) -> Self {
            PortFilter::Single(port)
        }

        pub fn range(start: u16, end: u16) -> Self {
            PortFilter::Range(start, end)
        }
    }

    pub struct WfpFirewall {
        engine_handle: HANDLE,
    }

    impl WfpFirewall {
        pub fn new() -> Result<Self> {
            unsafe {
                let mut engine_handle = HANDLE::default();

                let mut name = to_wstring("Rust WFP Session");
                let mut desc = to_wstring("Dynamic Session - Rules auto-cleanup on close");

                let session = FWPM_SESSION0 {
                    displayData: FWPM_DISPLAY_DATA0 {
                        name: PWSTR(name.as_mut_ptr()),
                        description: PWSTR(desc.as_mut_ptr()),
                    },
                    flags: FWPM_SESSION_FLAG_DYNAMIC,
                    ..Default::default()
                };

                let result = FwpmEngineOpen0(
                    None,
                    RPC_C_AUTHN_DEFAULT as u32,
                    None,
                    Some(&session),
                    &mut engine_handle,
                );

                if result != 0 {
                    bail!("无法打开 WFP 引擎，错误代码: {:#x}", result);
                }

                println!("✓ WFP 动态会话已创建（规则随引擎自动清理）");

                Ok(Self { engine_handle })
            }
        }

        pub fn add_rule(&mut self, rule: &FilterRule) -> Result<Vec<u64>> {
            let mut ids = Vec::new();

            let directions = match rule.direction {
                Direction::Inbound => vec![true],
                Direction::Outbound => vec![false],
                Direction::Both => vec![true, false],
            };

            let protocols = match rule.protocol {
                Protocol::TCP => vec![6u8],
                Protocol::UDP => vec![17u8],
                Protocol::Both => vec![6u8, 17u8],
                Protocol::Any => vec![],
            };

            for is_inbound in directions {
                if protocols.is_empty() {
                    ids.extend(self.add_filter_set(rule, is_inbound, None)?);
                } else {
                    for proto in &protocols {
                        ids.extend(self.add_filter_set(rule, is_inbound, Some(*proto))?);
                    }
                }
            }

            Ok(ids)
        }

        pub fn remove_filter(&mut self, filter_id: u64) -> Result<()> {
            unsafe {
                let status = FwpmFilterDeleteById0(self.engine_handle, filter_id);
                if status != 0 {
                    bail!("删除过滤器失败，错误代码: {:#x}", status);
                }
                Ok(())
            }
        }

        fn add_filter_set(
            &mut self,
            rule: &FilterRule,
            is_inbound: bool,
            protocol: Option<u8>,
        ) -> Result<Vec<u64>> {
            let mut ids = Vec::new();

            let layer_key_v4 = if is_inbound {
                &FWPM_LAYER_ALE_AUTH_RECV_ACCEPT_V4
            } else {
                &FWPM_LAYER_ALE_AUTH_CONNECT_V4
            };

            match self.add_filter(rule, layer_key_v4, protocol, false) {
                Ok(id) => ids.push(id),
                Err(err) => println!("⚠️  添加 IPv4 过滤器失败: {err}"),
            }

            let layer_key_v6 = if is_inbound {
                &FWPM_LAYER_ALE_AUTH_RECV_ACCEPT_V6
            } else {
                &FWPM_LAYER_ALE_AUTH_CONNECT_V6
            };

            match self.add_filter(rule, layer_key_v6, protocol, true) {
                Ok(id) => ids.push(id),
                Err(err) => println!("⚠️  添加 IPv6 过滤器失败: {err}"),
            }

            Ok(ids)
        }

        fn add_filter(
            &mut self,
            rule: &FilterRule,
            layer_key: *const windows::core::GUID,
            protocol: Option<u8>,
            is_ipv6: bool,
        ) -> Result<u64> {
            let mut data = create_filter(rule, layer_key, protocol, is_ipv6)?;

            let mut filter_id: u64 = 0;
            let result = unsafe {
                FwpmFilterAdd0(
                    self.engine_handle,
                    &data.filter,
                    None,
                    Some(&mut filter_id),
                )
            };

            drop(data);

            if result != 0 {
                bail!("添加过滤器失败，错误代码: {:#x}", result);
            }

            Ok(filter_id)
        }
    }

    impl Drop for WfpFirewall {
        fn drop(&mut self) {
            unsafe {
                if !self.engine_handle.is_invalid() {
                    println!("\n正在关闭 WFP 引擎（规则将自动清理）...");
                    FwpmEngineClose0(self.engine_handle);
                    println!("✓ WFP 引擎已关闭，所有规则已自动清理");
                }
            }
        }
    }

    struct FilterData {
        filter: FWPM_FILTER0,
        conditions: Box<[FWPM_FILTER_CONDITION0]>,
        name: Box<[u16]>,
        byte_arrays: Vec<Box<[u8]>>,
        blobs: Vec<Box<FWP_BYTE_BLOB>>,
        v4_masks: Vec<Box<FWP_V4_ADDR_AND_MASK>>,
        v6_masks: Vec<Box<FWP_V6_ADDR_AND_MASK>>,
        ranges: Vec<Box<FWP_RANGE0>>,
        array16: Vec<Box<[u8; 16]>>,
    }

    fn create_filter(
        rule: &FilterRule,
        layer_key: *const windows::core::GUID,
        protocol: Option<u8>,
        is_ipv6: bool,
    ) -> Result<FilterData> {
        let mut filter: FWPM_FILTER0 = unsafe { std::mem::zeroed() };
        let mut name = to_wstring(&rule.name).into_boxed_slice();
        filter.displayData.name = PWSTR(name.as_mut_ptr());
        filter.layerKey = unsafe { *layer_key };
        filter.subLayerKey = FWPM_SUBLAYER_UNIVERSAL;
        filter.action.r#type = match rule.action {
            RuleAction::Block => FWP_ACTION_BLOCK,
            RuleAction::Allow => FWP_ACTION_PERMIT,
        };
        filter.weight.r#type = FWP_UINT8;
        filter.weight.Anonymous.uint8 = 15;

        let mut conditions: Vec<FWPM_FILTER_CONDITION0> = Vec::new();
        let mut byte_arrays: Vec<Box<[u8]>> = Vec::new();
        let mut blobs: Vec<Box<FWP_BYTE_BLOB>> = Vec::new();
        let mut v4_masks: Vec<Box<FWP_V4_ADDR_AND_MASK>> = Vec::new();
        let mut v6_masks: Vec<Box<FWP_V6_ADDR_AND_MASK>> = Vec::new();
        let mut ranges: Vec<Box<FWP_RANGE0>> = Vec::new();
        let mut array16: Vec<Box<[u8; 16]>> = Vec::new();

        if let Some(ref app_path) = rule.application {
            let app_id_bytes = get_app_id(app_path)?;
            let boxed_bytes = app_id_bytes.into_boxed_slice();
            let mut blob = Box::new(FWP_BYTE_BLOB {
                size: boxed_bytes.len() as u32,
                data: boxed_bytes.as_ptr() as *mut u8,
            });
            let blob_ptr = blob.as_mut() as *mut _;

            let mut app_condition: FWPM_FILTER_CONDITION0 = unsafe { std::mem::zeroed() };
            app_condition.fieldKey = FWPM_CONDITION_ALE_APP_ID;
            app_condition.matchType = FWP_MATCH_EQUAL;
            app_condition.conditionValue.r#type = FWP_BYTE_BLOB_TYPE;
            app_condition.conditionValue.Anonymous.byteBlob = blob_ptr;

            conditions.push(app_condition);
            byte_arrays.push(boxed_bytes);
            blobs.push(blob);
        }

        if let Some(proto) = protocol {
            let mut proto_condition: FWPM_FILTER_CONDITION0 = unsafe { std::mem::zeroed() };
            proto_condition.fieldKey = FWPM_CONDITION_IP_PROTOCOL;
            proto_condition.matchType = FWP_MATCH_EQUAL;
            proto_condition.conditionValue.r#type = FWP_UINT8;
            proto_condition.conditionValue.Anonymous.uint8 = proto;
            conditions.push(proto_condition);
        }

        if let Some(ref remote_ip) = rule.remote_ip {
            add_ip_condition(
                &mut conditions,
                remote_ip,
                is_ipv6,
                true,
                &mut v4_masks,
                &mut v6_masks,
                &mut array16,
            )?;
        }

        if let Some(ref local_ip) = rule.local_ip {
            add_ip_condition(
                &mut conditions,
                local_ip,
                is_ipv6,
                false,
                &mut v4_masks,
                &mut v6_masks,
                &mut array16,
            )?;
        }

        if let Some(ref remote_port) = rule.remote_port {
            add_port_condition(
                &mut conditions,
                remote_port,
                true,
                &mut ranges,
            )?;
        }

        if let Some(ref local_port) = rule.local_port {
            add_port_condition(
                &mut conditions,
                local_port,
                false,
                &mut ranges,
            )?;
        }

        let mut conditions_box = conditions.into_boxed_slice();
        filter.numFilterConditions = conditions_box.len() as u32;
        filter.filterCondition = conditions_box.as_mut_ptr();

        Ok(FilterData {
            filter,
            conditions: conditions_box,
            name,
            byte_arrays,
            blobs,
            v4_masks,
            v6_masks,
            ranges,
            array16,
        })
    }

    fn add_ip_condition(
        conditions: &mut Vec<FWPM_FILTER_CONDITION0>,
        ip_filter: &IpFilter,
        is_ipv6: bool,
        is_remote: bool,
        v4_masks: &mut Vec<Box<FWP_V4_ADDR_AND_MASK>>,
        v6_masks: &mut Vec<Box<FWP_V6_ADDR_AND_MASK>>,
        array16: &mut Vec<Box<[u8; 16]>>,
    ) -> Result<()> {
        match ip_filter {
            IpFilter::Single(ip) => match (ip, is_ipv6) {
                (IpAddr::V4(ipv4), false) => {
                    let mut condition: FWPM_FILTER_CONDITION0 = unsafe { std::mem::zeroed() };
                    condition.fieldKey = if is_remote {
                        FWPM_CONDITION_IP_REMOTE_ADDRESS
                    } else {
                        FWPM_CONDITION_IP_LOCAL_ADDRESS
                    };
                    condition.matchType = FWP_MATCH_EQUAL;
                    condition.conditionValue.r#type = FWP_UINT32;
                    condition.conditionValue.Anonymous.uint32 = u32::from_be_bytes(ipv4.octets());
                    conditions.push(condition);
                }
                (IpAddr::V6(ipv6), true) => {
                    let boxed = Box::new(ipv6.octets());
                    let ptr = boxed.as_ptr() as *mut _;
                    let mut condition: FWPM_FILTER_CONDITION0 = unsafe { std::mem::zeroed() };
                    condition.fieldKey = if is_remote {
                        FWPM_CONDITION_IP_REMOTE_ADDRESS
                    } else {
                        FWPM_CONDITION_IP_LOCAL_ADDRESS
                    };
                    condition.matchType = FWP_MATCH_EQUAL;
                    condition.conditionValue.r#type = FWP_BYTE_ARRAY16_TYPE;
                    condition.conditionValue.Anonymous.byteArray16 = ptr;
                    conditions.push(condition);
                    array16.push(boxed);
                }
                _ => {}
            },
            IpFilter::Network(network) => match network {
                IpNetwork::V4(net) if !is_ipv6 => {
                    let boxed = Box::new(FWP_V4_ADDR_AND_MASK {
                        addr: u32::from_be_bytes(net.network().octets()),
                        mask: u32::from_be_bytes(net.mask().octets()),
                    });
                    let ptr = (&*boxed) as *const _ as *mut _;
                    let mut condition: FWPM_FILTER_CONDITION0 = unsafe { std::mem::zeroed() };
                    condition.fieldKey = if is_remote {
                        FWPM_CONDITION_IP_REMOTE_ADDRESS
                    } else {
                        FWPM_CONDITION_IP_LOCAL_ADDRESS
                    };
                    condition.matchType = FWP_MATCH_EQUAL;
                    condition.conditionValue.r#type = FWP_V4_ADDR_MASK;
                    condition.conditionValue.Anonymous.v4AddrMask = ptr;
                    conditions.push(condition);
                    v4_masks.push(boxed);
                }
                IpNetwork::V6(net) if is_ipv6 => {
                    let boxed = Box::new(FWP_V6_ADDR_AND_MASK {
                        addr: net.network().octets(),
                        prefixLength: net.prefix(),
                    });
                    let ptr = (&*boxed) as *const _ as *mut _;
                    let mut condition: FWPM_FILTER_CONDITION0 = unsafe { std::mem::zeroed() };
                    condition.fieldKey = if is_remote {
                        FWPM_CONDITION_IP_REMOTE_ADDRESS
                    } else {
                        FWPM_CONDITION_IP_LOCAL_ADDRESS
                    };
                    condition.matchType = FWP_MATCH_EQUAL;
                    condition.conditionValue.r#type = FWP_V6_ADDR_MASK;
                    condition.conditionValue.Anonymous.v6AddrMask = ptr;
                    conditions.push(condition);
                    v6_masks.push(boxed);
                }
                _ => {}
            },
        }
        Ok(())
    }

    fn add_port_condition(
        conditions: &mut Vec<FWPM_FILTER_CONDITION0>,
        port_filter: &PortFilter,
        is_remote: bool,
        ranges: &mut Vec<Box<FWP_RANGE0>>,
    ) -> Result<()> {
        match port_filter {
            PortFilter::Single(port) => {
                let mut condition: FWPM_FILTER_CONDITION0 = unsafe { std::mem::zeroed() };
                condition.fieldKey = if is_remote {
                    FWPM_CONDITION_IP_REMOTE_PORT
                } else {
                    FWPM_CONDITION_IP_LOCAL_PORT
                };
                condition.matchType = FWP_MATCH_EQUAL;
                condition.conditionValue.r#type = FWP_UINT16;
                condition.conditionValue.Anonymous.uint16 = *port;
                conditions.push(condition);
            }
            PortFilter::Range(start, end) => {
                let boxed = Box::new(FWP_RANGE0 {
                    valueLow: FWP_VALUE0 {
                        r#type: FWP_UINT16,
                        Anonymous: FWP_VALUE0_0 { uint16: *start },
                    },
                    valueHigh: FWP_VALUE0 {
                        r#type: FWP_UINT16,
                        Anonymous: FWP_VALUE0_0 { uint16: *end },
                    },
                });
                let ptr = (&*boxed) as *const _ as *mut _;
                let mut condition: FWPM_FILTER_CONDITION0 = unsafe { std::mem::zeroed() };
                condition.fieldKey = if is_remote {
                    FWPM_CONDITION_IP_REMOTE_PORT
                } else {
                    FWPM_CONDITION_IP_LOCAL_PORT
                };
                condition.matchType = FWP_MATCH_RANGE;
                condition.conditionValue.r#type = FWP_RANGE_TYPE;
                condition.conditionValue.Anonymous.rangeValue = ptr;
                conditions.push(condition);
                ranges.push(boxed);
            }
        }
        Ok(())
    }

    fn to_wstring(s: &str) -> Vec<u16> {
        s.encode_utf16().chain(std::iter::once(0)).collect()
    }

    fn get_app_id(app_path: &str) -> Result<Vec<u8>> {
        let app_path_w = to_wstring(app_path);
        let mut app_id_ptr: *mut FWP_BYTE_BLOB = std::ptr::null_mut();

        let result = unsafe {
            FwpmGetAppIdFromFileName0(PCWSTR(app_path_w.as_ptr()), &mut app_id_ptr)
        };

        if result != 0 {
            bail!("获取应用 ID 失败，错误代码: {:#x}", result);
        }

        if app_id_ptr.is_null() {
            bail!("应用 ID 为空");
        }

        let app_id = unsafe { &*app_id_ptr };
        let bytes = unsafe { std::slice::from_raw_parts(app_id.data, app_id.size as usize) }.to_vec();

        unsafe {
            FwpmFreeMemory0(&mut app_id_ptr as *mut _ as *mut *mut _);
        }

        Ok(bytes)
    }

    pub fn convert_rule(rule: &MagicWallRule) -> Result<FilterRule> {
        let action = match rule.action.as_str() {
            "allow" => RuleAction::Allow,
            "block" => RuleAction::Block,
            other => bail!("不支持的动作: {other}"),
        };

        let protocol = match rule.protocol.as_str() {
            "tcp" => Protocol::TCP,
            "udp" => Protocol::UDP,
            "both" => Protocol::Both,
            "any" => Protocol::Any,
            other => bail!("不支持的协议: {other}"),
        };

        let direction = match rule.direction.as_str() {
            "inbound" => Direction::Inbound,
            "outbound" => Direction::Outbound,
            "both" => Direction::Both,
            other => bail!("不支持的方向: {other}"),
        };

        let mut f_rule = FilterRule::new(&rule.name, action)
            .protocol(protocol)
            .direction(direction);

        if let Some(app) = rule.app_path.as_ref().filter(|s| !s.trim().is_empty()) {
            f_rule = f_rule.application(app.clone());
        }

        if let Some(ref remote_ip) = rule.remote_ip {
            if !remote_ip.trim().is_empty() {
                f_rule = f_rule.remote_ip(parse_ip_filter(remote_ip)?);
            }
        }

        if let Some(ref local_ip) = rule.local_ip {
            if !local_ip.trim().is_empty() {
                f_rule = f_rule.local_ip(parse_ip_filter(local_ip)?);
            }
        }

        if let Some(ref remote_port) = rule.remote_port {
            if !remote_port.trim().is_empty() {
                f_rule = f_rule.remote_port(parse_port_filter(remote_port)?);
            }
        }

        if let Some(ref local_port) = rule.local_port {
            if !local_port.trim().is_empty() {
                f_rule = f_rule.local_port(parse_port_filter(local_port)?);
            }
        }

        Ok(f_rule)
    }

    fn parse_ip_filter(value: &str) -> Result<IpFilter> {
        if value.contains('/') {
            let network = IpNetwork::from_str(value.trim())?;
            Ok(IpFilter::network(network))
        } else {
            let ip = IpAddr::from_str(value.trim())?;
            Ok(IpFilter::single(ip))
        }
    }

    fn parse_port_filter(value: &str) -> Result<PortFilter> {
        if let Some((start, end)) = value.split_once('-') {
            let start: u16 = start.trim().parse()?;
            let end: u16 = end.trim().parse()?;
            Ok(PortFilter::range(start, end))
        } else {
            Ok(PortFilter::single(value.trim().parse()?))
        }
    }
}

#[cfg(target_os = "windows")]
use wfp_impl::{convert_rule, WfpFirewall};

#[cfg(target_os = "windows")]
lazy_static::lazy_static! {
    static ref FIREWALL: Mutex<Option<WfpFirewall>> = Mutex::new(None);
    static ref FILTER_TRACKER: Mutex<HashMap<String, Vec<u64>>> = Mutex::new(HashMap::new());
    static ref RULE_STORE: Mutex<HashMap<String, MagicWallRule>> = Mutex::new(HashMap::new());
}

/// 启动魔法墙引擎
#[cfg(target_os = "windows")]
pub fn start_magic_wall() -> std::result::Result<(), String> {
    let mut firewall_guard = FIREWALL.lock().map_err(|e| e.to_string())?;
    if firewall_guard.is_some() {
        return Err("魔法墙已经在运行".to_string());
    }

    let firewall = WfpFirewall::new().map_err(|e| e.to_string())?;
    println!("\n🔥 ============ 魔法墙引擎启动 ============");
    println!("✓ 引擎状态: 运行中");
    println!("✓ 平台: Windows Filtering Platform (WFP)");
    println!("============================================\n");

    *firewall_guard = Some(firewall);
    drop(firewall_guard);

    // 重新应用所有已启用的规则
    let rules = RULE_STORE.lock().map_err(|e| e.to_string())?;
    for rule in rules.values().filter(|r| r.enabled) {
        if let Err(err) = apply_rule(rule) {
            println!("⚠️  规则 {} 应用失败: {}", rule.name, err);
        }
    }

    Ok(())
}

/// 停止魔法墙引擎
#[cfg(target_os = "windows")]
pub fn stop_magic_wall() -> std::result::Result<(), String> {
    let mut firewall_guard = FIREWALL.lock().map_err(|e| e.to_string())?;
    if firewall_guard.is_none() {
        return Err("魔法墙未运行".to_string());
    }

    let active_count = RULE_STORE
        .lock()
        .map_err(|e| e.to_string())?
        .values()
        .filter(|r| r.enabled)
        .count();

    *firewall_guard = None;
    FILTER_TRACKER.lock().map_err(|e| e.to_string())?.clear();

    println!("\n🛑 ============ 魔法墙引擎停止 ============");
    println!("✓ 引擎状态: 已停止");
    println!("✓ 清理规则: {} 条活跃规则", active_count);
    println!("============================================\n");
    Ok(())
}

/// 添加规则
#[cfg(target_os = "windows")]
pub fn add_magic_wall_rule(rule: MagicWallRule) -> std::result::Result<(), String> {
    RULE_STORE
        .lock()
        .map_err(|e| e.to_string())?
        .insert(rule.id.clone(), rule.clone());

    if rule.enabled {
        apply_rule(&rule)?;
    } else {
        println!("⏸️  规则已添加但未启用: {}", rule.name);
    }

    Ok(())
}

#[cfg(target_os = "windows")]
fn apply_rule(rule: &MagicWallRule) -> std::result::Result<(), String> {
    println!("\n➕ ============ 添加防火墙规则 ============");
    println!("📌 规则名称: {}", rule.name);
    println!("🔑 规则 ID: {}", rule.id);
    println!("🎯 动作: {}", if rule.action == "allow" { "✅ 允许" } else { "🚫 阻止" });
    println!("📡 协议: {}", rule.protocol.to_uppercase());
    println!("🔄 方向: {}", match rule.direction.as_str() {
        "inbound" => "⬇️  入站",
        "outbound" => "⬆️  出站",
        "both" => "↕️  双向",
        _ => &rule.direction,
    });

    if let Some(app_path) = &rule.app_path {
        println!("💻 应用路径 (DOS): {}", app_path);
        if let Some(nt_path) = crate::api::nt::get_nt_path(app_path) {
            println!("💻 应用路径 (NT):  {}", nt_path);
        } else {
            println!("⚠️  无法转换为 NT 路径");
        }
    }

    if let Some(remote_ip) = &rule.remote_ip {
        println!("🌐 远程 IP: {}", remote_ip);
    }

    if let Some(local_ip) = &rule.local_ip {
        println!("🏠 本地 IP: {}", local_ip);
    }

    if let Some(remote_port) = &rule.remote_port {
        println!("🔌 远程端口: {}", remote_port);
    }

    if let Some(local_port) = &rule.local_port {
        println!("🔌 本地端口: {}", local_port);
    }

    if let Some(description) = &rule.description {
        println!("📝 说明: {}", description);
    }

    let mut firewall_guard = FIREWALL.lock().map_err(|e| e.to_string())?;
    if let Some(ref mut firewall) = *firewall_guard {
        let ids = convert_rule(rule)
            .and_then(|f_rule| firewall.add_rule(&f_rule))
            .map_err(|e| e.to_string())?;

        FILTER_TRACKER
            .lock()
            .map_err(|e| e.to_string())?
            .insert(rule.id.clone(), ids);

        println!("✅ 状态: 已启用");
        println!("============================================\n");
    } else {
        println!("⚠️  魔法墙尚未启动，规则将在启动后生效");
        println!("============================================\n");
    }

    Ok(())
}

/// 删除规则
#[cfg(target_os = "windows")]
pub fn remove_magic_wall_rule(rule_id: String) -> std::result::Result<(), String> {
    let mut rules = RULE_STORE.lock().map_err(|e| e.to_string())?;
    if let Some(rule) = rules.remove(&rule_id) {
        println!("\n➖ ============ 删除防火墙规则 ============");
        println!("📌 规则名称: {}", rule.name);
        println!("🔑 规则 ID: {}", rule.id);
        if let Some(app_path) = &rule.app_path {
            println!("💻 应用路径 (DOS): {}", app_path);
            if let Some(nt_path) = crate::api::nt::get_nt_path(app_path) {
                println!("💻 应用路径 (NT):  {}", nt_path);
            }
        }

        let mut firewall_guard = FIREWALL.lock().map_err(|e| e.to_string())?;
        if let Some(firewall) = firewall_guard.as_mut() {
            let ids = {
                let mut tracker = FILTER_TRACKER.lock().map_err(|e| e.to_string())?;
                tracker.remove(&rule_id)
            };

            if let Some(ids) = ids {
                for id in ids {
                    if let Err(err) = firewall.remove_filter(id) {
                        println!("⚠️  删除过滤器失败: {}", err);
                    }
                }
            }
        }

        println!("✅ 规则已从防火墙中移除");
        println!("============================================\n");
        Ok(())
    } else {
        println!("⚠️  规则不存在: {}", rule_id);
        Err("规则不存在".to_string())
    }
}

/// 更新规则
#[cfg(target_os = "windows")]
pub fn update_magic_wall_rule(rule: MagicWallRule) -> std::result::Result<(), String> {
    println!("\n🔄 ============ 更新防火墙规则 ============");
    println!("📌 规则名称: {}", rule.name);
    println!("🔑 规则 ID: {}", rule.id);
    println!("============================================\n");

    let _ = remove_magic_wall_rule(rule.id.clone());
    add_magic_wall_rule(rule)?;

    println!("✅ 规则更新完成\n");
    Ok(())
}

/// 获取魔法墙状态
#[cfg(target_os = "windows")]
pub fn get_magic_wall_status() -> std::result::Result<MagicWallStatus, String> {
    let running = FIREWALL.lock().map_err(|e| e.to_string())?.is_some();
    let rules = RULE_STORE.lock().map_err(|e| e.to_string())?;

    let active_rules = rules.values().filter(|r| r.enabled).count();
    let total_rules = rules.len();

    println!("📊 魔法墙状态查询:");
    println!("   引擎: {}", if running { "🟢 运行中" } else { "🔴 已停止" });
    println!("   活跃规则: {} / {} 条", active_rules, total_rules);

    Ok(MagicWallStatus {
        is_running: running,
        active_rules,
        total_rules,
    })
}

// ============= 非 Windows 平台实现 =============

#[cfg(not(target_os = "windows"))]
pub fn start_magic_wall() -> std::result::Result<(), String> {
    Err("魔法墙仅支持 Windows 平台".to_string())
}

#[cfg(not(target_os = "windows"))]
pub fn stop_magic_wall() -> std::result::Result<(), String> {
    Err("魔法墙仅支持 Windows 平台".to_string())
}

#[cfg(not(target_os = "windows"))]
pub fn add_magic_wall_rule(_rule: MagicWallRule) -> std::result::Result<(), String> {
    Err("魔法墙仅支持 Windows 平台".to_string())
}

#[cfg(not(target_os = "windows"))]
pub fn remove_magic_wall_rule(_rule_id: String) -> std::result::Result<(), String> {
    Err("魔法墙仅支持 Windows 平台".to_string())
}

#[cfg(not(target_os = "windows"))]
pub fn update_magic_wall_rule(_rule: MagicWallRule) -> std::result::Result<(), String> {
    Err("魔法墙仅支持 Windows 平台".to_string())
}

#[cfg(not(target_os = "windows"))]
pub fn get_magic_wall_status() -> std::result::Result<MagicWallStatus, String> {
    Ok(MagicWallStatus {
        is_running: false,
        active_rules: 0,
        total_rules: 0,
    })
}

// ============= 通用函数 =============

/// 创建默认规则示例
pub fn create_default_magic_wall_rules() -> Vec<MagicWallRule> {
    let now = chrono::Utc::now().timestamp();
    
    vec![
        MagicWallRule {
            id: uuid::Uuid::new_v4().to_string(),
            name: "阻止所有入站连接".to_string(),
            enabled: false,
            action: "block".to_string(),
            protocol: "both".to_string(),
            direction: "inbound".to_string(),
            app_path: None,
            remote_ip: None,
            local_ip: None,
            remote_port: None,
            local_port: None,
            description: Some("阻止所有入站的 TCP 和 UDP 连接".to_string()),
            created_at: Some(now),
        },
        MagicWallRule {
            id: uuid::Uuid::new_v4().to_string(),
            name: "允许本地网络".to_string(),
            enabled: false,
            action: "allow".to_string(),
            protocol: "both".to_string(),
            direction: "both".to_string(),
            app_path: None,
            remote_ip: Some("192.168.0.0/16".to_string()),
            local_ip: None,
            remote_port: None,
            local_port: None,
            description: Some("允许访问本地网络段".to_string()),
            created_at: Some(now),
        },
    ]
}
