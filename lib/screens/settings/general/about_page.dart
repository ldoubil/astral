import 'package:astral/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/screens/logs_page.dart';
import 'package:astral/utils/up.dart';
import 'package:signals_flutter/signals_flutter.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.about.tr()), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.star, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'Astral',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version ${AppState().baseState.latestVersion.watch(context)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Hero(
                    tag: "logs_hero",
                    child: const Icon(Icons.article),
                  ),
                  title: Text(LocaleKeys.view_logs.tr()),
                  subtitle: Text(LocaleKeys.view_logs_desc.tr()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _navigateToLogs(context),
                ),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.group),
                  title: Text(LocaleKeys.official_qq_group.tr()),
                  subtitle: Text(LocaleKeys.click_copy_group_number.tr()),
                  trailing: const Icon(Icons.copy),
                  onTap: () => _copyQQGroup(context),
                ),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.feedback),
                  title: Text(LocaleKeys.user_feedback.tr()),
                  subtitle: Text('提交问题反馈和建议'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _sendFeedback(context),
                ),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.update),
                  title: Text(LocaleKeys.check_update.tr()),
                  subtitle: Text('检查是否有新版本'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _checkForUpdates(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                // ListTile(
                //   title: Text('开源信息'),
                //   subtitle: Text('项目信息和许可证'),
                //   leading: const Icon(Icons.code),
                // ),

                // const Divider(),
                ListTile(
                  leading: const Icon(Icons.link),
                  title: Text('GitHub 仓库'),
                  subtitle: Text('github.com/ldoubil/astral'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openGitHub(context),
                ),

                // ListTile(
                //   leading: const Icon(Icons.balance),
                //   title: Text('开源许可证'),
                //   subtitle: Text('MIT License'),
                //   trailing: const Icon(Icons.chevron_right),
                //   onTap: () => _showLicense(context),
                // ),

                // ListTile(
                //   leading: const Icon(Icons.person),
                //   title: Text('开发者'),
                //   subtitle: Text('ldoubil'),
                // ),
              ],
            ),
          ),

          // const SizedBox(height: 16),

          // Card(
          //   child: Column(
          //     children: [
          //       ListTile(
          //         title: Text('致谢'),
          //         subtitle: Text('感谢以下项目和贡献者'),
          //         leading: const Icon(Icons.favorite),
          //       ),

          //       const Divider(),

          //       ListTile(
          //         leading: const Icon(Icons.flutter_dash),
          //         title: Text('Flutter'),
          //         subtitle: Text('跨平台UI框架'),
          //       ),

          //       ListTile(
          //         leading: const Icon(Icons.memory),
          //         title: Text('Rust'),
          //         subtitle: Text('高性能网络核心'),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  void _navigateToLogs(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const LogsPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  Future<void> _copyQQGroup(BuildContext context) async {
    const qqGroup = '808169040';
    await Clipboard.setData(const ClipboardData(text: qqGroup));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.group_number_copied.tr())),
      );
    }
  }

  void _sendFeedback(BuildContext context) async {
    final feedbackController = TextEditingController();
    final emailController = TextEditingController();
    final nameController = TextEditingController();

    final feedback = await showDialog<Map<String, String>>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(LocaleKeys.user_feedback.tr()),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: LocaleKeys.name.tr(),
                      hintText: LocaleKeys.name_hint.tr(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: LocaleKeys.email.tr(),
                      hintText: LocaleKeys.email_hint.tr(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: feedbackController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: LocaleKeys.feedback_content.tr(),
                      hintText: LocaleKeys.feedback_content_hint.tr(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(LocaleKeys.cancel.tr()),
              ),
              TextButton(
                onPressed:
                    () => Navigator.pop(context, {
                      'name': nameController.text,
                      'email': emailController.text,
                      'feedback': feedbackController.text,
                    }),
                child: Text(LocaleKeys.submit.tr()),
              ),
            ],
          ),
    );

    if (feedback != null &&
        feedback['feedback']?.trim().isNotEmpty == true &&
        feedback['email']?.trim().isNotEmpty == true &&
        feedback['name']?.trim().isNotEmpty == true) {
      // Handle feedback submission
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('反馈已提交，感谢您的建议！')));
      }
    }
  }

  void _checkForUpdates(BuildContext context) {
    final updateChecker = UpdateChecker(owner: 'ldoubil', repo: 'astral');
    if (context.mounted) {
      updateChecker.checkForUpdates(context);
    }
  }

  void _openGitHub(BuildContext context) {
    // Open GitHub repository
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('正在打开 GitHub 仓库...')));
  }

  void _showLicense(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('MIT License'),
            content: const SingleChildScrollView(
              child: Text(
                'MIT License\n\n'
                'Copyright (c) 2024 ldoubil\n\n'
                'Permission is hereby granted, free of charge, to any person obtaining a copy '
                'of this software and associated documentation files (the "Software"), to deal '
                'in the Software without restriction, including without limitation the rights '
                'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell '
                'copies of the Software, and to permit persons to whom the Software is '
                'furnished to do so, subject to the following conditions:\n\n'
                'The above copyright notice and this permission notice shall be included in all '
                'copies or substantial portions of the Software.\n\n'
                'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR '
                'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, '
                'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE '
                'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER '
                'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, '
                'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE '
                'SOFTWARE.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(LocaleKeys.close.tr()),
              ),
            ],
          ),
    );
  }
}
