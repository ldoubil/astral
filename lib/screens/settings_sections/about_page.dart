import 'package:astral/utils/up.dart';
import 'package:astral/screens/logs_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.about.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14.0),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Hero(
                    tag: "logs_hero",
                    child: const Icon(Icons.article),
                  ),
                  title: Text(LocaleKeys.view_logs.tr()),
                  subtitle: Text(LocaleKeys.view_logs_desc.tr()),
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                const LogsPage(),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
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
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.group),
                  title: Text(LocaleKeys.official_qq_group.tr()),
                  subtitle: Text(LocaleKeys.click_copy_group_number.tr()),
                  onTap: () async {
                    const qqGroup = '808169040'; // 替换为实际QQ群号
                    await Clipboard.setData(const ClipboardData(text: qqGroup));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(LocaleKeys.group_number_copied.tr()),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.feedback),
                  title: Text(LocaleKeys.user_feedback.tr()),
                  onTap: _sendFeedback,
                ),
                ListTile(
                  leading: const Icon(Icons.update),
                  title: Text(LocaleKeys.check_update.tr()),
                  onTap: () {
                    final updateChecker = UpdateChecker(
                      owner: 'ldoubil',
                      repo: 'astral',
                    );
                    updateChecker.checkForUpdates(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendFeedback() {
    // 这里可以实现反馈功能
  }
}