import 'package:flutter/material.dart';
import 'package:astral/widgets/home_box.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';

class HitokotoCard extends StatefulWidget {
  const HitokotoCard({super.key});

  @override
  State<HitokotoCard> createState() => _HitokotoCardState();
}

class _HitokotoCardState extends State<HitokotoCard> {
  String hitokoto = LocaleKeys.hitokoto_loading.tr();
  String hitokotoFrom = '';
  bool isLoadingHitokoto = true;

  @override
  void initState() {
    super.initState();
    _fetchHitokoto();
  }

  Future<void> _fetchHitokoto() async {
    try {
      final response = await http.get(Uri.parse('https://v1.hitokoto.cn/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          hitokoto = data['hitokoto'] ?? LocaleKeys.hitokoto_no_content.tr();
          hitokotoFrom = data['from'] ?? LocaleKeys.hitokoto_unknown_source.tr();
          isLoadingHitokoto = false;
        });
      } else {
        setState(() {
          hitokoto = LocaleKeys.hitokoto_fetch_failed.tr();
          hitokotoFrom = '';
          isLoadingHitokoto = false;
        });
      }
    } catch (e) {
      setState(() {
        hitokoto = LocaleKeys.hitokoto_network_error.tr();
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
              Icon(
                Icons.format_quote,
                color: colorScheme.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                LocaleKeys.hitokoto_title.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  size: 18,
                  color: colorScheme.primary,
                ),
                onPressed: isLoadingHitokoto ? null : () {
                  setState(() {
                    isLoadingHitokoto = true;
                    hitokoto = LocaleKeys.hitokoto_loading.tr();
                    hitokotoFrom = '';
                  });
                  _fetchHitokoto();
                },
                tooltip: LocaleKeys.hitokoto_refresh.tr(),
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
                  LocaleKeys.hitokoto_loading.tr(),
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