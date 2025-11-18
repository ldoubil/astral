import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// 头像URL输入对话框
/// 支持输入URL并验证其可行性（3秒超时）
class AvatarUrlDialog extends StatefulWidget {
  const AvatarUrlDialog({super.key, required this.currentUrl});

  final String currentUrl;

  @override
  State<AvatarUrlDialog> createState() => _AvatarUrlDialogState();
}

class _AvatarUrlDialogState extends State<AvatarUrlDialog> {
  final TextEditingController _urlController = TextEditingController();
  bool _isValidating = false;
  String? _errorMessage;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _urlController.text = widget.currentUrl;
    if (widget.currentUrl.isNotEmpty) {
      _isValid = true;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  /// 验证URL是否可访问
  Future<void> _validateUrl(String url) async {
    if (url.trim().isEmpty) {
      setState(() {
        _isValidating = false;
        _errorMessage = null;
        _isValid = true; // 允许清空
      });
      return;
    }

    // 基本URL格式验证
    if (!_isValidUrl(url)) {
      setState(() {
        _isValidating = false;
        _errorMessage = '请输入有效的URL地址';
        _isValid = false;
      });
      return;
    }

    setState(() {
      _isValidating = true;
      _errorMessage = null;
      _isValid = false;
    });

    try {
      // 使用3秒超时验证URL
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            },
          )
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () {
              throw TimeoutException('请求超时');
            },
          );

      if (mounted) {
        // 检查响应状态码和内容类型
        if (response.statusCode == 200) {
          final contentType = response.headers['content-type'] ?? '';
          if (contentType.startsWith('image/')) {
            setState(() {
              _isValidating = false;
              _errorMessage = null;
              _isValid = true;
            });
          } else {
            setState(() {
              _isValidating = false;
              _errorMessage = 'URL指向的不是图片资源';
              _isValid = false;
            });
          }
        } else {
          setState(() {
            _isValidating = false;
            _errorMessage = '无法访问该URL (状态码: ${response.statusCode})';
            _isValid = false;
          });
        }
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _isValidating = false;
          _errorMessage = '请求超时，无法访问该URL';
          _isValid = false;
        });
      }
    } on SocketException {
      if (mounted) {
        setState(() {
          _isValidating = false;
          _errorMessage = '网络连接失败，请检查URL是否正确';
          _isValid = false;
        });
      }
    } on FormatException {
      if (mounted) {
        setState(() {
          _isValidating = false;
          _errorMessage = 'URL格式不正确';
          _isValid = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isValidating = false;
          _errorMessage = '验证失败: ${e.toString()}';
          _isValid = false;
        });
      }
    }
  }

  /// 验证URL格式
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// 处理确认
  void _handleConfirm() {
    final url = _urlController.text.trim();
    if (url.isEmpty || _isValid) {
      Navigator.of(context).pop(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('设置头像'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: '输入头像图片URL',
              suffixIcon:
                  _isValidating
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                      : _isValid
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : _errorMessage != null
                      ? Icon(Icons.error, color: Colors.red)
                      : null,
            ),
            autofocus: true,
            onChanged: (value) {
              // 延迟验证，避免频繁请求
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted && _urlController.text == value) {
                  _validateUrl(value);
                }
              });
            },
            onSubmitted: (_) {
              if (_isValid || _urlController.text.trim().isEmpty) {
                _handleConfirm();
              }
            },
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
          if (_isValid && _urlController.text.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'URL验证成功',
              style: TextStyle(color: Colors.green, fontSize: 12),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed:
              (_isValid || _urlController.text.trim().isEmpty) && !_isValidating
                  ? _handleConfirm
                  : null,
          child: const Text('确定'),
        ),
      ],
    );
  }
}
