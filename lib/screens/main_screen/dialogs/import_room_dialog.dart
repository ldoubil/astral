import 'package:astral/models/room_info.dart';
import 'package:astral/utils/room_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 导入房间对话框
class ImportRoomDialog extends StatefulWidget {
  const ImportRoomDialog({super.key});

  @override
  State<ImportRoomDialog> createState() => _ImportRoomDialogState();
}

class _ImportRoomDialogState extends State<ImportRoomDialog> {
  final TextEditingController _jsonController = TextEditingController();
  String? _errorMessage;
  RoomInfo? _parsedRoom;

  @override
  void initState() {
    super.initState();
    _loadFromClipboard();
  }

  /// 从剪贴板加载 JSON
  Future<void> _loadFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      _jsonController.text = clipboardData!.text!;
      _validateJson();
    }
  }

  /// 验证 JSON 格式
  void _validateJson() {
    setState(() {
      _errorMessage = null;
      _parsedRoom = null;
    });

    final jsonText = _jsonController.text.trim();
    if (jsonText.isEmpty) {
      return;
    }

    final room = RoomExport.fromJson(jsonText);
    if (room == null) {
      setState(() {
        _errorMessage = 'JSON 格式错误，请检查输入内容';
      });
    } else {
      setState(() {
        _parsedRoom = room;
      });
    }
  }

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canImport = _parsedRoom != null;

    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '导入房间',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _jsonController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: '粘贴房间 JSON 信息...',
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
              ),
              onChanged: (_) => _validateJson(),
            ),
            if (_parsedRoom != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '房间信息预览',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '名称: ${_parsedRoom!.name}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      'UUID: ${_parsedRoom!.uuid}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '服务器数量: ${_parsedRoom!.servers.length}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: canImport
                      ? () => Navigator.of(context).pop(_parsedRoom)
                      : null,
                  child: const Text('导入'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

