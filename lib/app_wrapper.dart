import 'package:flutter/material.dart';
import 'package:astral/app.dart';

/// 应用包装器 - 直接显示主应用
class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const KevinApp();
  }
}