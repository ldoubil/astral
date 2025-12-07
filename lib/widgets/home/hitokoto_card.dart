import 'package:flutter/material.dart';
import 'package:astral/widgets/home_box.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HitokotoCard extends StatefulWidget {
  const HitokotoCard({super.key});

  @override
  State<HitokotoCard> createState() => _HitokotoCardState();
}

class _HitokotoCardState extends State<HitokotoCard> {
  String hitokoto = '加载中...';
  String hitokotoFrom = '';
  bool isLoadingHitokoto = true;

  @override
  void initState() {
    super.initState();
    _fetchHitokoto();
  }

  @override
  void dispose() {
    // 清理资源，防止内存泄漏
    super.dispose();
  }

  Future<void> _fetchHitokoto() async {
    try {
      final response = await http.get(Uri.parse('https://v1.hitokoto.cn/'));
      if (!mounted) return; // 检查 widget 是否还在树中

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return; // 再次检查
        setState(() {
          hitokoto = data['hitokoto'] ?? '暂无内容';
          hitokotoFrom = data['from'] ?? '未知来源';
          isLoadingHitokoto = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          hitokoto = '获取失败';
          hitokotoFrom = '';
          isLoadingHitokoto = false;
        });
      }
    } catch (e) {
      if (!mounted) return; // 捕获异常后也要检查
      setState(() {
        hitokoto = '网络错误';
        hitokotoFrom = '';
        isLoadingHitokoto = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return HomeBox(
      widthSpan: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote, color: colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                '一言',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.refresh, size: 18, color: colorScheme.primary),
                onPressed:
                    isLoadingHitokoto
                        ? null
                        : () {
                          setState(() {
                            isLoadingHitokoto = true;
                            hitokoto = '加载中...';
                            hitokotoFrom = '';
                          });
                          _fetchHitokoto();
                        },
                tooltip: '刷新一言',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoadingHitokoto)
            Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '加载中...',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hitokoto,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
                if (hitokotoFrom.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    '—— $hitokotoFrom',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
