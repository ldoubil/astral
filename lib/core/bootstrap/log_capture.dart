import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:astral/core/services/service_manager.dart';

/// UDP 日志捕获（单例）
class LogCapture {
  static LogCapture? _instance;
  RawDatagramSocket? _udpSocket;
  bool _isCapturing = false;

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
    try {
      _udpSocket = await RawDatagramSocket.bind(InternetAddress(host), port);
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
                if (kDebugMode) {
                  debugPrint('UDP log decode error: $e');
                }
              }
            }
          }
        },
        onError: (error) {
          if (kDebugMode) {
            debugPrint('UDP socket error: $error');
          }
          _isCapturing = false;
        },
        onDone: () {
          _isCapturing = false;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to start UDP log capture: $e');
      }
      _isCapturing = false;
      rethrow;
    }
  }

  void _addLogToSignal(String logEntry) {
    final currentLogs = List<String>.from(
      ServiceManager().appSettingsState.logs.value,
    );
    currentLogs.add(logEntry);

    if (currentLogs.length > 1000) {
      currentLogs.removeRange(0, currentLogs.length - 1000);
    }

    ServiceManager().appSettingsState.logs.value = currentLogs;
  }
}
