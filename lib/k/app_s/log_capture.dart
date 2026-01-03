import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:astral/k/services/service_manager.dart';

/// 日志捕获管理器 - 单例类
class LogCapture {
  static LogCapture? _instance;
  RawDatagramSocket? _udpSocket;
  bool _isCapturing = false;

  // 工厂构造函数，获取单例实例
  factory LogCapture() {
    _instance ??= LogCapture._internal();
    return _instance!;
  }

  LogCapture._internal();

  /// 开始捕获UDP日志
  Future<void> startCapture({
    String host = '127.0.0.1',
    int port = 9999,
  }) async {
    if (_isCapturing) return;
    debugPrint('准备绑定UDP端口: $host:$port');
    try {
      _udpSocket = await RawDatagramSocket.bind(InternetAddress(host), port);
      debugPrint('UDP端口绑定成功: $host:$port');
      _isCapturing = true;
      _udpSocket!.listen(
        (RawSocketEvent event) {
          if (event == RawSocketEvent.read) {
            final datagram = _udpSocket!.receive();
            if (datagram != null) {
              try {
                final logData = utf8.decode(datagram.data);
                if (logData.isNotEmpty) {
                  _addLogToSignal(
                    '[${DateTime.now().toString().substring(11, 19)}] $logData',
                  );
                }
              } catch (e) {
                debugPrint('UDP log decode error: $e');
              }
            }
          }
        },
        onError: (error) {
          debugPrint('UDP socket error: $error');
          _isCapturing = false;
        },
        onDone: () {
          _isCapturing = false;
        },
      );
      debugPrint('UDP log capture started on $host:$port');
    } catch (e) {
      debugPrint('Failed to start UDP log capture: $e');
      _isCapturing = false;
      rethrow; // 关键：抛出异常，避免卡住
    }
  }

  /// 停止捕获日志
  void stopCapture() {
    _udpSocket?.close();
    _udpSocket = null;
    _isCapturing = false;
    debugPrint('UDP log capture stopped');
  }

  /// 房间直接添加日志
  void addRoomLog(String roomName, String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logEntry = '[$timestamp] [$roomName] $message';
    _addLogToSignal(logEntry);
  }

  /// 添加系统日志
  void addSystemLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logEntry = '[$timestamp] [SYSTEM] $message';
    _addLogToSignal(logEntry);
  }

  /// 添加网络日志
  void addNetworkLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logEntry = '[$timestamp] [NETWORK] $message';
    _addLogToSignal(logEntry);
  }

  /// 添加连接日志
  void addConnectionLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logEntry = '[$timestamp] [CONNECTION] $message';
    _addLogToSignal(logEntry);
  }

  /// 添加错误日志
  void addErrorLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logEntry = '[$timestamp] [ERROR] $message';
    _addLogToSignal(logEntry);
  }

  /// 添加UDP原始日志（不添加时间戳，直接使用原始数据）
  void addRawUdpLog(String message) {
    _addLogToSignal(message);
  }

  /// 清空日志
  void clearLogs() {
    final currentLogs = List<String>.from(
      ServiceManager().appSettingsState.logs.value,
    );
    currentLogs.clear();
    ServiceManager().appSettingsState.logs.value = currentLogs;
  }

  /// 获取最近的日志条目
  List<String> getRecentLogs(int count) {
    final currentLogs = ServiceManager().appSettingsState.logs.value;
    if (currentLogs.length <= count) {
      return List<String>.from(currentLogs);
    }
    return currentLogs.sublist(currentLogs.length - count);
  }

  /// 根据关键词过滤日志
  List<String> filterLogs(String keyword) {
    final currentLogs = ServiceManager().appSettingsState.logs.value;
    return currentLogs
        .where((log) => log.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }

  /// 根据日志类型过滤
  List<String> filterLogsByType(String type) {
    final currentLogs = ServiceManager().appSettingsState.logs.value;
    return currentLogs.where((log) => log.contains('[$type]')).toList();
  }

  /// 内部方法：添加日志到信号
  void _addLogToSignal(String logEntry) {
    final currentLogs = List<String>.from(
      ServiceManager().appSettingsState.logs.value,
    );
    currentLogs.add(logEntry);
    debugPrint('ERROR: $logEntry');

    // 限制日志数量，保留最新的1000条
    if (currentLogs.length > 1000) {
      currentLogs.removeRange(0, currentLogs.length - 1000);
    }

    ServiceManager().appSettingsState.logs.value = currentLogs;
  }

  /// 获取捕获状态
  bool get isCapturing => _isCapturing;

  /// 获取日志总数
  int get logCount => ServiceManager().appSettingsState.logs.value.length;

  /// 导出日志为字符串
  String exportLogsAsString() {
    return ServiceManager().appSettingsState.logs.value.join('\n');
  }

  /// 获取UDP Socket信息
  String? get socketInfo {
    if (_udpSocket != null) {
      return '${_udpSocket!.address.address}:${_udpSocket!.port}';
    }
    return null;
  }
}
