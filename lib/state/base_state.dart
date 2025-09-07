import 'dart:io';

import 'package:astral/data/database/persistent_signal_extension.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signals_flutter/signals_flutter.dart';

class BaseState {
  static final BaseState _instance = BaseState._internal();
  factory BaseState() {
    return _instance;
  }

  final currentPage = signal('home');
  final showDebugConsole = signal<bool>(true);
  final appDataDirectory = signal<String?>(null);
  // 软件资源目录
  final resourceDirectory = signal("")
    ..persistWith('app_settings', 'resourceDirectory');

  BaseState._internal() {
    init();
  }

  void init() async {
    final directory = await getApplicationSupportDirectory();
    appDataDirectory.value = directory.path;
    if (resourceDirectory.value.isEmpty && (resourceDirectory.value == "")) {
      resourceDirectory.value = "${directory.path}\\resourceDirectory";
      // 然后创建
      await Directory(resourceDirectory.value).create(recursive: true);
    }
  }

  final java8Directory = signal("")
    ..persistWith('app_settings', 'java8Directory');
  final java17Directory = signal("")
    ..persistWith('app_settings', 'java17Directory');
  final java21Directory = signal("")
    ..persistWith('app_settings', 'java21Directory');
}
