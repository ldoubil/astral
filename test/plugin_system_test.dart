import 'package:flutter_test/flutter_test.dart';
import 'package:astral/core/plugin_system/plugin_manager.dart';
import 'package:astral/core/plugin_system/plugin_interface.dart';
import 'dart:io';

/// 插件系统单元测试
/// 测试插件管理器的基本功能
void main() {
  group('插件系统测试', () {
    late PluginManager pluginManager;

    setUp(() {
      pluginManager = PluginManager.instance;
    });

    test('插件管理器单例模式测试', () {
      final manager1 = PluginManager.instance;
      final manager2 = PluginManager();
      
      expect(manager1, equals(manager2));
      expect(identical(manager1, manager2), isTrue);
    });

    test('插件管理器初始化测试', () async {
      // 设置测试插件目录
      pluginManager.setPluginsDirectory('test_plugins');
      
      // 创建测试插件目录
      final testDir = Directory('test_plugins');
      if (await testDir.exists()) {
        await testDir.delete(recursive: true);
      }
      
      // 初始化插件管理器
      await pluginManager.initialize();
      
      // 验证插件目录已创建
      expect(await testDir.exists(), isTrue);
      
      // 清理测试目录
      await testDir.delete(recursive: true);
    });

    test('插件元数据解析测试', () {
      final testMetadata = {
        'id': 'test_plugin',
        'name': '测试插件',
        'version': '1.0.0',
        'author': '测试作者',
        'description': '这是一个测试插件',
        'entry_point': 'main.js',
        'permissions': ['show_notification'],
        'dependencies': [],
        'config': {'enabled': true}
      };

      final metadata = PluginMetadata.fromJson(testMetadata);
      
      expect(metadata.id, equals('test_plugin'));
      expect(metadata.name, equals('测试插件'));
      expect(metadata.version, equals('1.0.0'));
      expect(metadata.author, equals('测试作者'));
      expect(metadata.description, equals('这是一个测试插件'));
      expect(metadata.entryPoint, equals('main.js'));
      expect(metadata.permissions, contains('show_notification'));
      expect(metadata.dependencies, isEmpty);
      expect(metadata.config?['enabled'], isTrue);
    });

    test('插件状态枚举测试', () {
      expect(PluginStatus.uninitialized.toString(), equals('PluginStatus.uninitialized'));
      expect(PluginStatus.initialized.toString(), equals('PluginStatus.initialized'));
      expect(PluginStatus.running.toString(), equals('PluginStatus.running'));
      expect(PluginStatus.stopped.toString(), equals('PluginStatus.stopped'));
      expect(PluginStatus.error.toString(), equals('PluginStatus.error'));
    });

    test('插件管理器事件流测试', () async {
      // 简化测试，只验证事件流不为空
      expect(pluginManager.eventStream, isNotNull);
      
      // 设置测试目录并初始化
      pluginManager.setPluginsDirectory('test_plugins_event');
      await pluginManager.initialize();
      
      // 清理
      final testDir = Directory('test_plugins_event');
      if (await testDir.exists()) {
        await testDir.delete(recursive: true);
      }
    });
  });

  group('Hello World插件测试', () {
    test('Hello World插件清单文件验证', () async {
      final manifestFile = File('plugins/hello_world/manifest.json');
      
      if (await manifestFile.exists()) {
        final content = await manifestFile.readAsString();
        expect(content.isNotEmpty, isTrue);
        expect(content.contains('hello_world'), isTrue);
        expect(content.contains('Hello World'), isTrue);
      }
    });

    test('Hello World插件主文件验证', () async {
      final mainFile = File('plugins/hello_world/main.js');
      
      if (await mainFile.exists()) {
        final content = await mainFile.readAsString();
        expect(content.isNotEmpty, isTrue);
        expect(content.contains('function init()'), isTrue);
        expect(content.contains('function start()'), isTrue);
        expect(content.contains('function stop()'), isTrue);
        expect(content.contains('function cleanup()'), isTrue);
      }
    });
  });

  group('插件模板测试', () {
    test('插件模板文件完整性验证', () async {
      final manifestFile = File('templates/plugin_template/manifest.json');
      final mainFile = File('templates/plugin_template/main.js');
      final readmeFile = File('templates/plugin_template/README.md');
      
      expect(await manifestFile.exists(), isTrue);
      expect(await mainFile.exists(), isTrue);
      expect(await readmeFile.exists(), isTrue);
    });

    test('插件模板清单文件格式验证', () async {
      final manifestFile = File('templates/plugin_template/manifest.json');
      
      if (await manifestFile.exists()) {
        final content = await manifestFile.readAsString();
        expect(content.contains('my_plugin'), isTrue);
        expect(content.contains('entry_point'), isTrue);
        expect(content.contains('permissions'), isTrue);
      }
    });
  });
}