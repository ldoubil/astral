/// Hive适配器TypeId常量定义
/// 统一管理所有适配器的TypeId，避免冲突和硬编码
class AdapterTypeIds {
  /// Color适配器的TypeId
  static const int color = 33;
  
  /// ThemeMode适配器的TypeId
  static const int themeMode = 34;
  
  // 预留的TypeId范围：
  // 35-50: 核心UI类型
  // 51-100: 业务模型类型
  // 101+: 其他自定义类型
  
  /// 私有构造函数，防止实例化
  AdapterTypeIds._();
}