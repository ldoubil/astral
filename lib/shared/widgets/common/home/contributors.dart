import 'package:astral/shared/widgets/common/home_box.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';

class Contributors extends StatefulWidget {
  const Contributors({super.key});

  @override
  State<Contributors> createState() => _ContributorsState();
}

class _ContributorsState extends State<Contributors> {
  List<Map<String, dynamic>> contributors = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchContributors();
  }

  Future<void> _fetchContributors() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await http.get(
        Uri.parse('https://api.github.com/repos/ldoubil/astral/contributors'),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        setState(() {
          contributors = data.map((contributor) {
            final String login = contributor['login'] ?? '';
            final bool isAuthor = login == 'ldoubil';
            
            // 根据贡献数量和用户名确定角色
            String role;
            if (isAuthor) {
              role = LocaleKeys.project_author_maintainer.tr();
            } else if (contributor['contributions'] >= 30) {
              role = LocaleKeys.core_contributor.tr();
            } else if (contributor['contributions'] >= 5) {
              role = LocaleKeys.contributor.tr();
            } else if (login.contains('bot')) {
              role = LocaleKeys.automation_assistant.tr();
            } else {
              role = LocaleKeys.contributor.tr();
            }
            
            return {
              'name': login,
              'role': role,
              'avatar': contributor['avatar_url'] ?? '',
              'github': contributor['html_url'] ?? '',
              'isAuthor': isAuthor,
              'contributions': contributor['contributions'] ?? 0,
            };
          }).toList();
          
          // 按贡献数量排序，作者始终在最前面
          contributors.sort((a, b) {
            if (a['isAuthor']) return -1;
            if (b['isAuthor']) return 1;
            return (b['contributions'] as int).compareTo(a['contributions'] as int);
          });
          
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load contributors: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = '${LocaleKeys.load_contributors_failed.tr()}: $e';
        // 使用备用数据
        contributors = [
          {
            'name': 'ldoubil',
            'role': LocaleKeys.project_author_maintainer.tr(),
            'avatar': 'https://avatars.githubusercontent.com/u/26994456?v=4',
            'github': 'https://github.com/ldoubil',
            'isAuthor': true,
            'contributions': 446,
          },
        ];
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
                Icons.people_outline,
                color: colorScheme.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                LocaleKeys.contributors.tr(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              if (isLoading) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          if (errorMessage != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: colorScheme.onErrorContainer,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: TextStyle(
                        color: colorScheme.onErrorContainer,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (isLoading)
             Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(LocaleKeys.loading_contributors.tr()),
              ),
            )
          else
            ...contributors.map((contributor) => _buildContributorItem(
                  contributor,
                  colorScheme,
                )),
          const SizedBox(height: 8),
          // 查看更多贡献者链接
          InkWell(
            onTap: () => _launchUrl('https://github.com/ldoubil/astral/graphs/contributors'),
            child: Row(
              children: [
                Icon(
                  Icons.open_in_new,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  LocaleKeys.view_all_contributors.tr(),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributorItem(
    Map<String, dynamic> contributor,
    ColorScheme colorScheme,
  ) {
    final bool isAuthor = contributor['isAuthor'] ?? false;
    final int contributions = contributor['contributions'] ?? 0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _launchUrl(contributor['github']!),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isAuthor 
                  ? colorScheme.primary.withOpacity(0.5)
                  : colorScheme.outline.withOpacity(0.2),
              width: isAuthor ? 2 : 1,
            ),
            gradient: isAuthor
                ? LinearGradient(
                    colors: [
                      colorScheme.primary.withOpacity(0.05),
                      colorScheme.primary.withOpacity(0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Row(
            children: [
              // 头像
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    backgroundImage: contributor['avatar'].isNotEmpty 
                        ? NetworkImage(contributor['avatar']!) 
                        : null,
                    child: contributor['avatar'].isEmpty 
                        ? Icon(
                            Icons.person,
                            color: colorScheme.primary,
                            size: 20,
                          )
                        : null,
                  ),
                  if (isAuthor)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // 贡献者信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contributor['name']!,
                            style: TextStyle(
                              fontWeight: isAuthor ? FontWeight.w900 : FontWeight.bold,
                              fontSize: isAuthor ? 15 : 14,
                              color: isAuthor ? colorScheme.primary : null,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAuthor) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified,
                            color: colorScheme.primary,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contributor['role']!,
                            style: TextStyle(
                              color: isAuthor 
                                  ? colorScheme.primary.withOpacity(0.8)
                                  : colorScheme.secondary,
                              fontSize: 12,
                              fontWeight: isAuthor ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        Text(
                          '$contributions 次贡献',
                          style: TextStyle(
                            color: colorScheme.secondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // GitHub 图标
              Icon(
                Icons.code,
                color: isAuthor ? colorScheme.primary : colorScheme.primary.withOpacity(0.7),
                size: isAuthor ? 20 : 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}