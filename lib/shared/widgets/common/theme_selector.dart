import 'package:astral/core/services/service_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void showThemeColorPicker(BuildContext context) {
  // 保存当前颜色，用于取消时恢复
  final currentColor = ServiceManager().themeState.themeColor.value;
  // 临时颜色，用于预览
  Color tempColor = currentColor;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('选择主题颜色'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 使用更简单的BlockPicker替代复杂的ColorPicker
                  BlockPicker(
                    pickerColor: tempColor,
                    onColorChanged: (color) {
                      // 更新临时颜色并立即预览
                      setState(() {
                        tempColor = color;
                      });
                      // 立即更新主题以预览效果
                      ServiceManager().theme.updateThemeColor(color);
                    },
                    availableColors: const [
                      Colors.red,
                      Colors.pink,
                      Colors.purple,
                      Colors.deepPurple,
                      Colors.indigo,
                      Colors.blue,
                      Colors.lightBlue,
                      Colors.cyan,
                      Colors.teal,
                      Colors.green,
                      Colors.lightGreen,
                      Colors.lime,
                      Colors.yellow,
                      Colors.amber,
                      Colors.orange,
                      Colors.deepOrange,
                      Colors.brown,
                      Colors.grey,
                      Colors.blueGrey,
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 添加一个自定义颜色按钮
                  ElevatedButton.icon(
                    icon: const Icon(Icons.color_lens),
                    label: const Text('自定义颜色'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showAdvancedColorPicker(
                        context,
                        tempColor, // 使用临时颜色作为初始值
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('取消'),
                onPressed: () {
                  // 取消时恢复原来的颜色
                  ServiceManager().theme.updateThemeColor(currentColor);
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('确定'),
                onPressed: () {
                  // 确定时保持当前颜色（已经在预览中更新了）
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    },
  );
}

void _showAdvancedColorPicker(BuildContext context, Color initialColor) {
  Color pickerColor = initialColor;
  final currentColor = ServiceManager().themeState.themeColor.value;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('自定义颜色'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: (color) {
                  setState(() {
                    pickerColor = color;
                  });
                  // 立即更新主题以预览效果
                  ServiceManager().theme.updateThemeColor(color);
                },
                pickerAreaHeightPercent: 0.8,
                enableAlpha: false,
                displayThumbColor: true,
                paletteType: PaletteType.hsvWithHue,
                pickerAreaBorderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                labelTypes: const [ColorLabelType.rgb, ColorLabelType.hex],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('取消'),
                onPressed: () {
                  // 取消时恢复原来的颜色
                  ServiceManager().theme.updateThemeColor(currentColor);
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('确定'),
                onPressed: () {
                  // 确定时保持当前颜色（已经在预览中更新了）
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    },
  );
}
