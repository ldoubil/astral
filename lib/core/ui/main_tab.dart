/// 主导航 Tab（与 MainScreen.navigationItems 顺序一致）
enum MainTab {
  home,
  room,
  tools,
  servers,
  settings;

  static MainTab? tryFromIndex(int index) {
    if (index < 0 || index >= MainTab.values.length) return null;
    return MainTab.values[index];
  }
}
