import 'dart:async';
import 'package:astral/k/services/service_manager.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:astral/widgets/home_box.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:fl_chart/fl_chart.dart';

class TrafficStats extends StatefulWidget {
  const TrafficStats({super.key});

  @override
  State<TrafficStats> createState() => _TrafficStatsState();
}

class TrafficDataPoint {
  final DateTime timestamp;
  final BigInt rxBytes;
  final BigInt txBytes;

  TrafficDataPoint({
    required this.timestamp,
    required this.rxBytes,
    required this.txBytes,
  });
}

class _TrafficStatsState extends State<TrafficStats> {
  KVNetworkStatus? _networkStatus;
  bool _isLoading = true;
  Timer? _refreshTimer;
  final List<TrafficDataPoint> _historyData = [];
  static const int _maxHistoryPoints = 20; // 保留最近20个数据点
  static const int _displayPoints = 10; // 显示最近10个数据点
  double _maxTrafficCache = 100; // 缓存最大值，避免Y轴抖动

  @override
  void initState() {
    super.initState();
    // 初始化时添加0数据点
    _historyData.add(
      TrafficDataPoint(
        timestamp: DateTime.now(),
        rxBytes: BigInt.zero,
        txBytes: BigInt.zero,
      ),
    );
    _loadTrafficData();
    // 每3秒自动刷新一次
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _loadTrafficData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTrafficData() async {
    try {
      final status = await getNetworkStatus();
      if (mounted) {
        final (totalRx, totalTx) = _calculateTotalTrafficFromStatus(status);

        // 添加历史数据点
        _historyData.add(
          TrafficDataPoint(
            timestamp: DateTime.now(),
            rxBytes: totalRx,
            txBytes: totalTx,
          ),
        );

        // 保持最多20个数据点
        if (_historyData.length > _maxHistoryPoints) {
          _historyData.removeAt(0);
        }

        // 更新最大值缓存，动态调整Y轴范围
        final currentMax = _getMaxTraffic();
        final currentMin = _getMinTraffic();

        // 计算数据范围
        final dataRange = currentMax - currentMin;

        // 让数据占据图表高度的60%，中心在40%位置
        // 这意味着数据范围应该是总范围的60%
        final totalRange = dataRange / 0.6;

        // 中心在40%位置，所以底部留40% - 30% = 10%，顶部留60% - 30% = 30%
        final minY = currentMin - totalRange * 0.1;
        final maxY = currentMax + totalRange * 0.3;

        if (maxY > _maxTrafficCache || minY < 0) {
          _maxTrafficCache = maxY > 0 ? maxY : 100;
        }

        setState(() {
          _networkStatus = status;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 获取历史数据中的最小流量值
  double _getMinTraffic() {
    if (_historyData.isEmpty) return 0;

    double minTotal = double.infinity;

    for (var data in _historyData) {
      final total = (data.rxBytes + data.txBytes).toDouble();
      if (total < minTotal) minTotal = total;
    }

    return minTotal == double.infinity ? 0 : minTotal;
  }

  /// 从状态计算总流量
  (BigInt, BigInt) _calculateTotalTrafficFromStatus(KVNetworkStatus status) {
    BigInt totalRx = BigInt.zero;
    BigInt totalTx = BigInt.zero;

    for (var node in status.nodes) {
      totalRx += node.rxBytes;
      totalTx += node.txBytes;
    }

    return (totalRx, totalTx);
  }

  /// 格式化字节数为人类可读格式
  String _formatBytes(BigInt bytes) {
    if (bytes < BigInt.from(1024)) {
      return '$bytes B';
    } else if (bytes < BigInt.from(1024 * 1024)) {
      return '${(bytes.toDouble() / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < BigInt.from(1024 * 1024 * 1024)) {
      return '${(bytes.toDouble() / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes.toDouble() / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// 计算总流量
  (BigInt, BigInt) _calculateTotalTraffic() {
    if (_networkStatus == null) return (BigInt.zero, BigInt.zero);

    BigInt totalRx = BigInt.zero;
    BigInt totalTx = BigInt.zero;

    for (var node in _networkStatus!.nodes) {
      totalRx += node.rxBytes;
      totalTx += node.txBytes;
    }

    return (totalRx, totalTx);
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    // 获取最近10个数据点用于显示
    final displayData =
        _historyData.length > _displayPoints
            ? _historyData.sublist(_historyData.length - _displayPoints)
            : _historyData;

    return HomeBox(
      widthSpan: 2,
      fixedCellHeight: 180,
      isBorder: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: SizedBox(
              width: constraints.maxWidth - 24,
              height: constraints.maxHeight - 32,
              child: LineChart(
                LineChartData(
                  backgroundColor: Colors.transparent,
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (displayData.length - 1).toDouble(),
                  minY: 0,
                  maxY: _maxTrafficCache,
                  lineTouchData: LineTouchData(enabled: false),
                  clipData: FlClipData.all(),
                  baselineY: 0,
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: 0,
                        color: Colors.transparent,
                        strokeWidth: 0,
                      ),
                    ],
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots:
                          displayData.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              (entry.value.rxBytes + entry.value.txBytes)
                                  .toDouble(),
                            );
                          }).toList(),
                      isCurved: true,
                      color: colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withOpacity(0.3),
                            colorScheme.primary.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      preventCurveOverShooting: true,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 获取历史数据中的最大流量值
  double _getMaxTraffic() {
    if (_historyData.isEmpty) return 0;

    double maxRx = 0;
    double maxTx = 0;

    for (var data in _historyData) {
      final rx = data.rxBytes.toDouble();
      final tx = data.txBytes.toDouble();
      if (rx > maxRx) maxRx = rx;
      if (tx > maxTx) maxTx = tx;
    }

    return maxRx > maxTx ? maxRx : maxTx;
  }

  /// 格式化字节数为简短格式（用于图表）
  String _formatBytesShort(BigInt bytes) {
    if (bytes < BigInt.from(1024)) {
      return '${bytes}B';
    } else if (bytes < BigInt.from(1024 * 1024)) {
      return '${(bytes.toDouble() / 1024).toStringAsFixed(0)}K';
    } else if (bytes < BigInt.from(1024 * 1024 * 1024)) {
      return '${(bytes.toDouble() / (1024 * 1024)).toStringAsFixed(0)}M';
    } else {
      return '${(bytes.toDouble() / (1024 * 1024 * 1024)).toStringAsFixed(1)}G';
    }
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildTrafficItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
