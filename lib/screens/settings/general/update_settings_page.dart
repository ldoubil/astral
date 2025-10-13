import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/k/app_s/aps.dart1';
import 'package:astral/utils/up.dart';

class UpdateSettingsPage extends StatelessWidget {
  const UpdateSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.update_settings.tr()),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _checkForUpdates(context),
            tooltip: LocaleKeys.check_update.tr(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(LocaleKeys.update_settings.tr()),
                  subtitle: Text('Configure update behavior and channels'),
                  leading: const Icon(Icons.system_update),
                ),

                const Divider(),

                SwitchListTile(
                  title: Text(LocaleKeys.join_beta.tr()),
                  subtitle: Text(LocaleKeys.join_beta_desc.tr()),
                  value: Aps().beta.watch(context),
                  onChanged: (value) {
                    Aps().setBeta(value);
                  },
                ),

                if (!Aps().beta.watch(context))
                  SwitchListTile(
                    title: Text(LocaleKeys.auto_update.tr()),
                    subtitle: Text(LocaleKeys.auto_update_desc.tr()),
                    value: Aps().autoCheckUpdate.watch(context),
                    onChanged: (value) {
                      Aps().setAutoCheckUpdate(value);
                    },
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(LocaleKeys.download_acceleration.tr()),
                  subtitle: Text('Configure download acceleration'),
                  leading: const Icon(Icons.speed),
                ),

                const Divider(),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: LocaleKeys.download_acceleration.tr(),
                      hintText: LocaleKeys.download_acceleration_hint.tr(),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.link),
                    ),
                    initialValue: Aps().downloadAccelerate.watch(context),
                    onChanged: (value) {
                      Aps().setDownloadAccelerate(value);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text('更新操作'),
                  subtitle: Text('手动检查更新和版本信息'),
                  leading: const Icon(Icons.update),
                ),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: Text(LocaleKeys.check_update.tr()),
                  subtitle: Text('检查是否有新版本可用'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _checkForUpdates(context),
                ),

                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text('版本信息'),
                  subtitle: Text('查看当前版本和更新日志'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showVersionInfo(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text('更新说明'),
                  subtitle: Text('了解不同更新设置的作用'),
                  leading: const Icon(Icons.help_outline),
                ),

                const Divider(),

                ListTile(
                  title: Text('Beta 版本'),
                  subtitle: Text('抢先体验新功能，但可能存在稳定性问题'),
                  leading: const Icon(Icons.science),
                ),

                ListTile(
                  title: Text('自动更新'),
                  subtitle: Text('在后台自动检查并提醒更新'),
                  leading: const Icon(Icons.auto_awesome),
                ),

                ListTile(
                  title: Text('下载加速'),
                  subtitle: Text('使用镜像地址加速下载速度'),
                  leading: const Icon(Icons.speed),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _checkForUpdates(BuildContext context) {
    final updateChecker = UpdateChecker(owner: 'ldoubil', repo: 'astral');
    if (context.mounted) {
      updateChecker.checkForUpdates(context);
    }
  }

  void _showVersionInfo(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('版本信息'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('当前版本: 1.0.0'),
                const SizedBox(height: 8),
                Text('构建时间: 2024-01-01'),
                const SizedBox(height: 8),
                Text('更新通道: ${Aps().beta.value ? "Beta" : "Stable"}'),
              ],
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
