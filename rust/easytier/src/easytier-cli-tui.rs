use std::{
    io::{stdout, Stdout},
    net::SocketAddr,
    time::{Duration, Instant},
};

use anyhow::{Context, Result};
use clap::Parser;
use crossterm::{
    event::{self, DisableMouseCapture, EnableMouseCapture, Event, KeyCode, KeyEventKind},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use ratatui::{
    backend::CrosstermBackend,
    layout::{Alignment, Constraint, Direction, Layout, Rect},
    style::{Color, Modifier, Style},
    text::{Line, Span},
    widgets::{
        Block, Borders, Clear, Gauge, Paragraph, Row, Table, TableState,
        Tabs, Wrap,
    },
    Frame, Terminal,
};
use tokio::time::timeout;
use uuid::Uuid;

use easytier::{
    common::constants::EASYTIER_VERSION,
    proto::{
        api::{
            instance::{
                instance_identifier::{InstanceSelector, Selector},
                InstanceIdentifier, ListPeerRequest, ListPeerResponse, ListRouteRequest,
                ListRouteResponse, PeerManageRpc, PeerManageRpcClientFactory,
                ShowNodeInfoRequest,
            },
        },
        rpc_impl::standalone::StandAloneClient,
        rpc_types::controller::BaseController,
    },
    tunnel::tcp::TcpTunnelConnector,
};

/// EasyTier TUI 客户端
#[derive(Parser, Debug)]
#[command(name = "easytier-cli-tui", author, version = EASYTIER_VERSION, about = "EasyTier TUI 客户端", long_about = None)]
struct Cli {
    /// EasyTier Core RPC 门户地址
    #[arg(
        short = 'p',
        long,
        default_value = "127.0.0.1:15888",
        help = "easytier-core rpc portal address"
    )]
    rpc_portal: SocketAddr,

    /// 实例 ID
    #[arg(short = 'i', long = "instance-id", help = "the instance id")]
    instance_id: Option<Uuid>,

    /// 实例名称
    #[arg(short = 'n', long = "instance-name", help = "the instance name")]
    instance_name: Option<String>,

    /// 刷新间隔（秒）
    #[arg(short = 'r', long = "refresh", default_value = "5", help = "refresh interval in seconds")]
    refresh_interval: u64,
}

type RpcClient = StandAloneClient<TcpTunnelConnector>;

/// 应用状态
#[derive(Debug)]
struct App {
    /// 当前选中的标签页
    current_tab: usize,
    /// 标签页标题
    tab_titles: Vec<String>,
    /// 节点信息
    node_info: Option<NodeInfo>,
    /// 对等节点列表
    peers: Vec<PeerInfo>,
    /// 路由信息
    routes: Vec<RouteInfo>,
    /// 统计信息
    stats: Option<StatsInfo>,
    /// 表格状态
    peer_table_state: TableState,
    route_table_state: TableState,
    /// 错误信息
    error_message: Option<String>,
    /// 最后更新时间
    last_update: Instant,
    /// 是否正在加载
    loading: bool,
}

/// 对等节点信息
#[derive(Debug, Clone)]
struct PeerInfo {
    peer_id: String,
    conn_count: usize,
    rx_bytes: u64,
    tx_bytes: u64,
    latency_ms: u32,
    status: String,
}

/// 节点信息
type NodeInfo = easytier::proto::api::instance::NodeInfo;

/// 路由信息
#[derive(Debug, Clone)]
struct RouteInfo {
    ipv4_addr: String,
    hostname: String,
    proxy_cidrs: Vec<String>,
    next_hop_peer_id: String,
    cost: u32,
}

/// 统计信息
#[derive(Debug, Clone)]
struct StatsInfo {
    total_peers: usize,
    active_connections: usize,
    total_rx_bytes: u64,
    total_tx_bytes: u64,
    uptime: Duration,
}

impl App {
    /// 创建新的应用实例
    fn new() -> Self {
        Self {
            current_tab: 0,
            tab_titles: vec![
                "概览".to_string(),
                "对等节点".to_string(),
                "路由信息".to_string(),
                "统计信息".to_string(),
            ],
            node_info: None,
            peers: Vec::new(),
            routes: Vec::new(),
            stats: None,
            peer_table_state: TableState::default(),
            route_table_state: TableState::default(),
            error_message: None,
            last_update: Instant::now(),
            loading: false,
        }
    }

    /// 切换到下一个标签页
    fn next_tab(&mut self) {
        self.current_tab = (self.current_tab + 1) % self.tab_titles.len();
    }

    /// 切换到上一个标签页
    fn previous_tab(&mut self) {
        if self.current_tab > 0 {
            self.current_tab -= 1;
        } else {
            self.current_tab = self.tab_titles.len() - 1;
        }
    }

    /// 在对等节点表格中向下移动
    fn next_peer(&mut self) {
        if !self.peers.is_empty() {
            let i = match self.peer_table_state.selected() {
                Some(i) => {
                    if i >= self.peers.len() - 1 {
                        0
                    } else {
                        i + 1
                    }
                }
                None => 0,
            };
            self.peer_table_state.select(Some(i));
        }
    }

    /// 在对等节点表格中向上移动
    fn previous_peer(&mut self) {
        if !self.peers.is_empty() {
            let i = match self.peer_table_state.selected() {
                Some(i) => {
                    if i == 0 {
                        self.peers.len() - 1
                    } else {
                        i - 1
                    }
                }
                None => 0,
            };
            self.peer_table_state.select(Some(i));
        }
    }

    /// 在路由表格中向下移动
    fn next_route(&mut self) {
        if !self.routes.is_empty() {
            let i = match self.route_table_state.selected() {
                Some(i) => {
                    if i >= self.routes.len() - 1 {
                        0
                    } else {
                        i + 1
                    }
                }
                None => 0,
            };
            self.route_table_state.select(Some(i));
        }
    }

    /// 在路由表格中向上移动
    fn previous_route(&mut self) {
        if !self.routes.is_empty() {
            let i = match self.route_table_state.selected() {
                Some(i) => {
                    if i == 0 {
                        self.routes.len() - 1
                    } else {
                        i - 1
                    }
                }
                None => 0,
            };
            self.route_table_state.select(Some(i));
        }
    }

    /// 设置错误信息
    fn set_error(&mut self, error: String) {
        self.error_message = Some(error);
        self.loading = false;
    }

    /// 清除错误信息
    fn clear_error(&mut self) {
        self.error_message = None;
    }

    /// 开始加载
    fn start_loading(&mut self) {
        self.loading = true;
        self.clear_error();
    }

    /// 停止加载
    fn stop_loading(&mut self) {
        self.loading = false;
        self.last_update = Instant::now();
    }
}

/// TUI 应用程序
struct TuiApp {
    terminal: Terminal<CrosstermBackend<Stdout>>,
    app: App,
    rpc_client: RpcClient,
    instance_selector: InstanceIdentifier,
    refresh_interval: Duration,
}

impl TuiApp {
    /// 创建新的 TUI 应用程序
    async fn new(
        rpc_portal: SocketAddr,
        instance_id: Option<Uuid>,
        instance_name: Option<String>,
        refresh_interval: u64,
    ) -> Result<Self> {
        // 设置终端
        enable_raw_mode()?;
        let mut stdout = stdout();
        execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
        let backend = CrosstermBackend::new(stdout);
        let terminal = Terminal::new(backend)?;

        // 创建 RPC 客户端
        let rpc_client = StandAloneClient::new(TcpTunnelConnector::new(format!("tcp://{}", rpc_portal).parse().unwrap()));

        // 创建实例选择器
        let instance_selector = InstanceIdentifier {
            selector: if let Some(id) = instance_id {
                Some(Selector::Id(id.into()))
            } else if let Some(name) = instance_name {
                Some(Selector::InstanceSelector(InstanceSelector {
                    name: Some(name),
                }))
            } else {
                None
            },
        };

        Ok(Self {
            terminal,
            app: App::new(),
            rpc_client,
            instance_selector,
            refresh_interval: Duration::from_secs(refresh_interval),
        })
    }

    /// 运行 TUI 应用程序
    async fn run(&mut self) -> Result<()> {
        let mut last_refresh = Instant::now();

        // 初始数据加载
        self.refresh_data().await;

        loop {
            // 绘制界面
            {
                let app = &self.app;
                self.terminal.draw(|f| TuiApp::ui(f, app))?;
            }

            // 处理事件
            if event::poll(Duration::from_millis(100))? {
                if let Event::Key(key) = event::read()? {
                    if key.kind == KeyEventKind::Press {
                        match key.code {
                            KeyCode::Char('q') | KeyCode::Esc => break,
                            KeyCode::Tab => self.app.next_tab(),
                            KeyCode::BackTab => self.app.previous_tab(),
                            KeyCode::Down | KeyCode::Char('j') => {
                                match self.app.current_tab {
                                    1 => self.app.next_peer(),
                                    2 => self.app.next_route(),
                                    _ => {}
                                }
                            }
                            KeyCode::Up | KeyCode::Char('k') => {
                                match self.app.current_tab {
                                    1 => self.app.previous_peer(),
                                    2 => self.app.previous_route(),
                                    _ => {}
                                }
                            }
                            KeyCode::Char('r') | KeyCode::F(5) => {
                                self.refresh_data().await;
                            }
                            KeyCode::Char('c') => {
                                self.app.clear_error();
                            }
                            _ => {}
                        }
                    }
                }
            }

            // 自动刷新数据
            if last_refresh.elapsed() >= self.refresh_interval {
                self.refresh_data().await;
                last_refresh = Instant::now();
            }
        }

        Ok(())
    }

    /// 刷新数据
    async fn refresh_data(&mut self) {
        self.app.start_loading();

        // 获取节点信息
        if let Err(e) = self.fetch_node_info().await {
            self.app.set_error(format!("获取节点信息失败: {}", e));
            return;
        }

        // 获取对等节点信息
        if let Err(e) = self.fetch_peers().await {
            self.app.set_error(format!("获取对等节点信息失败: {}", e));
            return;
        }

        // 获取路由信息
        if let Err(e) = self.fetch_routes().await {
            self.app.set_error(format!("获取路由信息失败: {}", e));
            return;
        }

        // 更新统计信息
        self.update_stats();

        self.app.stop_loading();
    }

    /// 获取节点信息
    async fn fetch_node_info(&mut self) -> Result<()> {
        let client = self.rpc_client
            .scoped_client::<PeerManageRpcClientFactory<BaseController>>("".to_string())
            .await
            .context("创建对等节点管理客户端失败")?;

        let request = ShowNodeInfoRequest {
            instance: Some(self.instance_selector.clone()),
        };
        let response = timeout(Duration::from_secs(5), client.show_node_info(BaseController::default(), request))
            .await
            .context("请求超时")?
            .context("获取节点信息失败")?;

        if let Some(node_info) = response.node_info {
            // 直接使用 protobuf 生成的 NodeInfo 结构体
            self.app.node_info = Some(node_info);
        }

        Ok(())
    }

    /// 获取对等节点信息
    async fn fetch_peers(&mut self) -> Result<()> {
        let client = self.rpc_client
            .scoped_client::<PeerManageRpcClientFactory<BaseController>>("".to_string())
            .await
            .context("创建对等节点管理客户端失败")?;

        let request = ListPeerRequest {
            instance: Some(self.instance_selector.clone()),
        };
        let response: ListPeerResponse = timeout(Duration::from_secs(5), client.list_peer(BaseController::default(), request))
            .await
            .context("请求超时")?
            .context("获取对等节点信息失败")?;

        self.app.peers = response
            .peer_infos
            .into_iter()
            .map(|peer| PeerInfo {
                peer_id: peer.peer_id.to_string(),
                conn_count: peer.conns.len(),
                rx_bytes: peer.conns.iter().map(|c| c.stats.as_ref().map_or(0, |s| s.rx_bytes)).sum(),
                tx_bytes: peer.conns.iter().map(|c| c.stats.as_ref().map_or(0, |s| s.tx_bytes)).sum(),
                latency_ms: peer.conns.iter()
                    .filter_map(|c| c.stats.as_ref())
                    .map(|s| (s.latency_us / 1000) as u32)
                    .min()
                    .unwrap_or(0),
                status: if peer.conns.is_empty() { "离线".to_string() } else { "在线".to_string() },
            })
            .collect();

        // 更新节点信息
         if let Some(my_info) = response.my_info {
             // 直接使用 protobuf 生成的 NodeInfo 结构体
             self.app.node_info = Some(my_info);
         }

        Ok(())
    }

    /// 获取路由信息
    async fn fetch_routes(&mut self) -> Result<()> {
        let client = self.rpc_client
            .scoped_client::<PeerManageRpcClientFactory<BaseController>>("".to_string())
            .await
            .context("创建对等节点管理客户端失败")?;

        let request = ListRouteRequest {
            instance: Some(self.instance_selector.clone()),
        };
        let response: ListRouteResponse = timeout(Duration::from_secs(5), client.list_route(BaseController::default(), request))
            .await
            .context("请求超时")?
            .context("获取路由信息失败")?;

        self.app.routes = response
            .routes
            .into_iter()
            .map(|route| RouteInfo {
                ipv4_addr: route.ipv4_addr.map(|addr| addr.to_string()).unwrap_or_default(),
                hostname: route.hostname,
                proxy_cidrs: route.proxy_cidrs,
                next_hop_peer_id: route.next_hop_peer_id.to_string(),
                 cost: route.cost as u32,
            })
            .collect();

        Ok(())
    }

    /// 更新统计信息
    fn update_stats(&mut self) {
        let total_rx_bytes = self.app.peers.iter().map(|p| p.rx_bytes).sum();
        let total_tx_bytes = self.app.peers.iter().map(|p| p.tx_bytes).sum();

        self.app.stats = Some(StatsInfo {
            total_peers: self.app.peers.len(),
            active_connections: self.app.peers.len(),
            total_rx_bytes,
            total_tx_bytes,
            uptime: self.app.last_update.elapsed(),
        });
    }

    /// 绘制用户界面
    fn ui(f: &mut Frame, app: &App) {
        let size = f.size();

        // 创建主布局
        let chunks = Layout::default()
            .direction(Direction::Vertical)
            .constraints([
                Constraint::Length(3), // 标题栏
                Constraint::Min(0),    // 主内容区
                Constraint::Length(3), // 状态栏
            ])
            .split(size);

        // 绘制标题栏
        TuiApp::render_header(f, chunks[0]);

        // 绘制标签页
        let tab_chunks = Layout::default()
            .direction(Direction::Vertical)
            .constraints([Constraint::Length(3), Constraint::Min(0)])
            .split(chunks[1]);

        TuiApp::render_tabs(f, tab_chunks[0], app);

        // 绘制主内容
        match app.current_tab {
            0 => TuiApp::render_overview(f, tab_chunks[1], app),
            1 => TuiApp::render_peers(f, tab_chunks[1], app),
            2 => TuiApp::render_routes(f, tab_chunks[1], app),
            3 => TuiApp::render_stats(f, tab_chunks[1], app),
            _ => {}
        }

        // 绘制状态栏
        TuiApp::render_status_bar(f, chunks[2], app);

        // 绘制错误弹窗
        if app.error_message.is_some() {
            TuiApp::render_error_popup(f, size, app);
        }
    }

    /// 绘制标题栏
    fn render_header(f: &mut Frame, area: Rect) {
        let title = format!("EasyTier TUI v{}", EASYTIER_VERSION);
        let header = Paragraph::new(title)
            .style(Style::default().fg(Color::Cyan).add_modifier(Modifier::BOLD))
            .alignment(Alignment::Center)
            .block(
                Block::default()
                    .borders(Borders::ALL)
                    .border_style(Style::default().fg(Color::White)),
            );
        f.render_widget(header, area);
    }

    /// 绘制标签页
    fn render_tabs(f: &mut Frame, area: Rect, app: &App) {
        let titles: Vec<Line> = app
            .tab_titles
            .iter()
            .map(|t| Line::from(Span::styled(t, Style::default().fg(Color::White))))
            .collect();

        let tabs = Tabs::new(titles)
            .block(Block::default().borders(Borders::ALL).title("导航"))
            .select(app.current_tab)
            .style(Style::default().fg(Color::White))
            .highlight_style(
                Style::default()
                    .add_modifier(Modifier::BOLD)
                    .bg(Color::Blue)
                    .fg(Color::White),
            );

        f.render_widget(tabs, area);
    }

    /// 绘制概览页面
    fn render_overview(f: &mut Frame, area: Rect, app: &App) {
        let chunks = Layout::default()
            .direction(Direction::Vertical)
            .constraints([
                Constraint::Length(7),  // 节点信息
                Constraint::Length(5),  // 快速统计
                Constraint::Min(0),     // 其他信息
            ])
            .split(area);
    
        // 节点信息面板
        let node_block = Block::default()
            .title("节点信息")
            .borders(Borders::ALL)
            .border_style(Style::default().fg(Color::Blue));
    
        if let Some(node_info) = &app.node_info {
            let node_text = vec![
                Line::from(vec![
                    Span::styled("节点 ID: ", Style::default().fg(Color::Yellow)),
                    Span::raw(node_info.peer_id.to_string()),
                ]),
                Line::from(vec![
                    Span::styled("IPv4 地址: ", Style::default().fg(Color::Yellow)),
                    Span::raw(&node_info.ipv4_addr),
                ]),
                Line::from(vec![
                    Span::styled("主机名: ", Style::default().fg(Color::Yellow)),
                    Span::raw(&node_info.hostname),
                ]),
                Line::from(vec![
                    Span::styled("版本: ", Style::default().fg(Color::Yellow)),
                    Span::raw(&node_info.version),
                ]),
                Line::from(vec![
                    Span::styled("监听器: ", Style::default().fg(Color::Yellow)),
                    Span::raw(node_info.listeners.join(", ")),
                ]),
            ];
            let node_paragraph = Paragraph::new(node_text).block(node_block);
            f.render_widget(node_paragraph, chunks[0]);
        } else {
            let node_paragraph = Paragraph::new("正在加载节点信息...")
                .block(node_block)
                .style(Style::default().fg(Color::Gray));
            f.render_widget(node_paragraph, chunks[0]);
        }
    
        // 快速统计面板
        let stats_block = Block::default()
            .title("快速统计")
            .borders(Borders::ALL)
            .border_style(Style::default().fg(Color::Green));
    
        let stats_text = vec![
            Line::from(vec![
                Span::styled("对等节点数量: ", Style::default().fg(Color::Cyan)),
                Span::raw(app.peers.len().to_string()),
            ]),
            Line::from(vec![
                Span::styled("路由数量: ", Style::default().fg(Color::Cyan)),
                Span::raw(app.routes.len().to_string()),
            ]),
            Line::from(vec![
                Span::styled("在线节点: ", Style::default().fg(Color::Cyan)),
                Span::raw(app.peers.iter().filter(|p| p.status == "在线").count().to_string()),
            ]),
        ];
        let stats_paragraph = Paragraph::new(stats_text).block(stats_block);
        f.render_widget(stats_paragraph, chunks[1]);
    
        // 错误信息显示
        if let Some(error) = &app.error_message {
            let error_block = Block::default()
                .title("错误信息")
                .borders(Borders::ALL)
                .border_style(Style::default().fg(Color::Red));
            let error_paragraph = Paragraph::new(error.as_str())
                .block(error_block)
                .style(Style::default().fg(Color::Red))
                .wrap(Wrap { trim: true });
            f.render_widget(error_paragraph, chunks[2]);
        }
    }

    /// 绘制对等节点页面
    fn render_peers(f: &mut Frame, area: Rect, app: &App) {
        let header_cells = ["节点 ID", "连接数", "接收字节", "发送字节", "延迟", "状态"]
            .iter()
            .map(|h| ratatui::widgets::Cell::from(*h).style(Style::default().fg(Color::Yellow)));
        let header = Row::new(header_cells).height(1).bottom_margin(1);

        let rows = app.peers.iter().map(|peer| {
            Row::new(vec![
                ratatui::widgets::Cell::from(peer.peer_id.clone()),
                ratatui::widgets::Cell::from(peer.conn_count.to_string()),
                ratatui::widgets::Cell::from(format_bytes(peer.rx_bytes)),
                ratatui::widgets::Cell::from(format_bytes(peer.tx_bytes)),
                ratatui::widgets::Cell::from(format!("{}ms", peer.latency_ms)),
                ratatui::widgets::Cell::from(peer.status.clone()),
            ])
        });

        let table = Table::new(rows, [
            Constraint::Length(20),
            Constraint::Length(10),
            Constraint::Length(15),
            Constraint::Length(15),
            Constraint::Length(10),
            Constraint::Length(10),
        ])
        .header(header)
        .block(
            Block::default()
                .borders(Borders::ALL)
                .title("对等节点")
                .border_style(Style::default().fg(Color::White)),
        )
        .highlight_style(Style::default().add_modifier(Modifier::REVERSED))
        .highlight_symbol(">> ");

        // Note: Cannot render stateful widget without mutable reference
        f.render_widget(table, area);
    }

    /// 绘制路由页面
    fn render_routes(f: &mut Frame, area: Rect, app: &App) {
        let header_cells = ["目标 IP", "主机名", "下一跳", "代价"]
            .iter()
            .map(|h| ratatui::widgets::Cell::from(*h).style(Style::default().fg(Color::Yellow)));
        let header = Row::new(header_cells).height(1).bottom_margin(1);

        let rows = app.routes.iter().map(|route| {
            Row::new(vec![
                ratatui::widgets::Cell::from(route.ipv4_addr.clone()),
                ratatui::widgets::Cell::from(route.hostname.clone()),
                ratatui::widgets::Cell::from(route.next_hop_peer_id.clone()),
                ratatui::widgets::Cell::from(route.cost.to_string()),
            ])
        });

        let table = Table::new(rows, [
            Constraint::Length(20),
            Constraint::Length(25),
            Constraint::Length(20),
            Constraint::Length(10),
        ])
        .header(header)
        .block(
            Block::default()
                .borders(Borders::ALL)
                .title("路由信息")
                .border_style(Style::default().fg(Color::White)),
        )
        .highlight_style(Style::default().add_modifier(Modifier::REVERSED))
        .highlight_symbol(">> ");

        // Note: Cannot render stateful widget without mutable reference
        f.render_widget(table, area);
    }

    /// 绘制统计页面
    fn render_stats(f: &mut Frame, area: Rect, app: &App) {
        if let Some(stats) = &app.stats {
            let chunks = Layout::default()
                .direction(Direction::Vertical)
                .constraints([
                    Constraint::Length(3),
                    Constraint::Length(3),
                    Constraint::Length(3),
                    Constraint::Min(0),
                ])
                .split(area);

            // 对等节点数量
            let peers_gauge = Gauge::default()
                .block(Block::default().title("对等节点数").borders(Borders::ALL))
                .gauge_style(Style::default().fg(Color::Blue))
                .percent((stats.total_peers.min(100) * 100 / 100.max(1)) as u16)
                .label(format!("{} 个节点", stats.total_peers));
            f.render_widget(peers_gauge, chunks[0]);

            // 接收数据
            let rx_gauge = Gauge::default()
                .block(Block::default().title("接收数据").borders(Borders::ALL))
                .gauge_style(Style::default().fg(Color::Green))
                .percent(50) // 这里可以根据实际需要计算百分比
                .label(format_bytes(stats.total_rx_bytes));
            f.render_widget(rx_gauge, chunks[1]);

            // 发送数据
            let tx_gauge = Gauge::default()
                .block(Block::default().title("发送数据").borders(Borders::ALL))
                .gauge_style(Style::default().fg(Color::Red))
                .percent(50) // 这里可以根据实际需要计算百分比
                .label(format_bytes(stats.total_tx_bytes));
            f.render_widget(tx_gauge, chunks[2]);

            // 详细统计信息
            let detailed_stats = vec![
                Line::from(vec![
                    Span::styled("活跃连接: ", Style::default().fg(Color::Cyan)),
                    Span::raw(stats.active_connections.to_string()),
                ]),
                Line::from(vec![
                    Span::styled("运行时间: ", Style::default().fg(Color::Cyan)),
                    Span::raw(format_duration(stats.uptime)),
                ]),
            ];

            let stats_paragraph = Paragraph::new(detailed_stats)
                .block(
                    Block::default()
                        .title("详细统计")
                        .borders(Borders::ALL)
                        .border_style(Style::default().fg(Color::White)),
                )
                .wrap(Wrap { trim: true });

            f.render_widget(stats_paragraph, chunks[3]);
        }
    }

    /// 绘制状态栏
    fn render_status_bar(f: &mut Frame, area: Rect, app: &App) {
        let loading_indicator = if app.loading { " [加载中...]" } else { "" };
        let last_update = format!(
            "最后更新: {}{}",
            app.last_update.elapsed().as_secs(),
            loading_indicator
        );

        let help_text = "按键: Tab/Shift+Tab(切换标签) ↑↓/jk(导航) r/F5(刷新) c(清除错误) q/Esc(退出)";

        let status_chunks = Layout::default()
            .direction(Direction::Horizontal)
            .constraints([Constraint::Percentage(70), Constraint::Percentage(30)])
            .split(area);

        let help = Paragraph::new(help_text)
            .style(Style::default().fg(Color::White))
            .block(
                Block::default()
                    .borders(Borders::ALL)
                    .border_style(Style::default().fg(Color::White)),
            );

        let status = Paragraph::new(last_update)
            .style(Style::default().fg(Color::White))
            .alignment(Alignment::Right)
            .block(
                Block::default()
                    .borders(Borders::ALL)
                    .border_style(Style::default().fg(Color::White)),
            );

        f.render_widget(help, status_chunks[0]);
        f.render_widget(status, status_chunks[1]);
    }

    /// 绘制错误弹窗
    fn render_error_popup(f: &mut Frame, area: Rect, app: &App) {
        if let Some(error_msg) = &app.error_message {
            let popup_area = centered_rect(60, 20, area);

            f.render_widget(Clear, popup_area);

            let error_text = vec![
                Line::from(Span::styled(
                    "错误",
                    Style::default().fg(Color::Red).add_modifier(Modifier::BOLD),
                )),
                Line::from(""),
                Line::from(Span::raw(error_msg)),
                Line::from(""),
                Line::from(Span::styled(
                    "按 'c' 键关闭此消息",
                    Style::default().fg(Color::Yellow),
                )),
            ];

            let error_paragraph = Paragraph::new(error_text)
                .block(
                    Block::default()
                        .title("错误")
                        .borders(Borders::ALL)
                        .border_style(Style::default().fg(Color::Red)),
                )
                .alignment(Alignment::Center)
                .wrap(Wrap { trim: true });

            f.render_widget(error_paragraph, popup_area);
        }
    }
}

impl Drop for TuiApp {
    /// 清理终端状态
    fn drop(&mut self) {
        let _ = disable_raw_mode();
        let _ = execute!(
            self.terminal.backend_mut(),
            LeaveAlternateScreen,
            DisableMouseCapture
        );
        let _ = self.terminal.show_cursor();
    }
}

/// 格式化字节数
fn format_bytes(bytes: u64) -> String {
    const UNITS: &[&str] = &["B", "KB", "MB", "GB", "TB"];
    let mut size = bytes as f64;
    let mut unit_index = 0;

    while size >= 1024.0 && unit_index < UNITS.len() - 1 {
        size /= 1024.0;
        unit_index += 1;
    }

    format!("{:.2} {}", size, UNITS[unit_index])
}

/// 格式化持续时间
fn format_duration(duration: Duration) -> String {
    let total_seconds = duration.as_secs();
    let hours = total_seconds / 3600;
    let minutes = (total_seconds % 3600) / 60;
    let seconds = total_seconds % 60;

    if hours > 0 {
        format!("{}h {}m {}s", hours, minutes, seconds)
    } else if minutes > 0 {
        format!("{}m {}s", minutes, seconds)
    } else {
        format!("{}s", seconds)
    }
}

/// 创建居中的矩形区域
fn centered_rect(percent_x: u16, percent_y: u16, r: Rect) -> Rect {
    let popup_layout = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Percentage((100 - percent_y) / 2),
            Constraint::Percentage(percent_y),
            Constraint::Percentage((100 - percent_y) / 2),
        ])
        .split(r);

    Layout::default()
        .direction(Direction::Horizontal)
        .constraints([
            Constraint::Percentage((100 - percent_x) / 2),
            Constraint::Percentage(percent_x),
            Constraint::Percentage((100 - percent_x) / 2),
        ])
        .split(popup_layout[1])[1]
}

/// 主函数
#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();

    let mut app = TuiApp::new(
        cli.rpc_portal,
        cli.instance_id,
        cli.instance_name,
        cli.refresh_interval,
    )
    .await?;

    app.run().await?;

    Ok(())
}