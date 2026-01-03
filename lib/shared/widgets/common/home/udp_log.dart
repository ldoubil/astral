import 'dart:io';
import 'package:astral/shared/widgets/common/home_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';

class UdpLog extends StatefulWidget {
  const UdpLog({super.key});

  @override
  State<UdpLog> createState() => _UdpLogState();
}

class _UdpLogState extends State<UdpLog> {
  RawDatagramSocket? _socket;
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();
  bool _expanded = false; // 新增：控制折叠状态

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() async {
    _socket = await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 9999);
    _socket?.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        final datagram = _socket?.receive();
        if (datagram != null) {
          String msg;
          try {
            msg = utf8.decode(datagram.data);
          } catch (_) {
            try {
              // GBK 解码
              msg = const Utf8Decoder(
                allowMalformed: true,
              ).convert(datagram.data);
            } catch (_) {
              try {
                // Latin1 解码
                msg = latin1.decode(datagram.data);
              } catch (_) {
                // 都失败则显示为十六进制
                msg =
                    '【编码解析错误】' +
                    datagram.data
                        .map((b) => b.toRadixString(16).padLeft(2, '0'))
                        .join(' ');
              }
            }
          }
          setState(() {
            _logs.add(msg);
          });
          // 自动滚动到底部
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(
                _scrollController.position.maxScrollExtent,
              );
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _socket?.close();
    _scrollController.dispose();
    super.dispose();
  }

  void _copyLogs() {
    final logsText = _logs.join('\n');
    Clipboard.setData(ClipboardData(text: logsText));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(LocaleKeys.logs_copied.tr())));
  }

  @override
  Widget build(BuildContext context) {
    // 检测当前主题模式
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return HomeBox(
      widthSpan: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                LocaleKeys.udp_log_listener.tr(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                tooltip: _expanded ? LocaleKeys.collapse_log.tr() : LocaleKeys.expand_log.tr(),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                tooltip: LocaleKeys.copy_all_logs.tr(),
                onPressed: _logs.isEmpty ? null : _copyLogs,
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState:
                _expanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
            firstChild: SizedBox(
              height: 200,
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black87 : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Scrollbar(
                  controller: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      return SelectableText(
                        _logs[index],
                        style: TextStyle(
                          color: isDarkMode ? Colors.greenAccent : Colors.black,
                          fontFamily: 'monospace',
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
