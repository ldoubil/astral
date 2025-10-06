/// 通用序列化接口
/// 任何需要持久化的对象都应该实现这个接口
abstract class Serializable {
  /// 将对象转换为 Map
  Map<String, dynamic> toMap();
  
  /// 从 Map 创建对象的静态方法
  /// 注意：这个方法需要在具体类中实现
  /// 例如：static ServerDb fromMap(Map<String, dynamic> map) => ...
}

/// 序列化工厂接口
/// 用于创建对象实例
abstract class SerializableFactory<T extends Serializable> {
  /// 从 Map 创建对象
  T fromMap(Map<String, dynamic> map);
  
  /// 获取类型名称
  String get typeName;
}

/// 序列化注册表
/// 管理所有可序列化类型的工厂
class SerializationRegistry {
  static final SerializationRegistry _instance = SerializationRegistry._();
  factory SerializationRegistry() => _instance;
  
  final Map<String, SerializableFactory> _factories = {};
  
  SerializationRegistry._();
  
  /// 注册序列化工厂
  void register<T extends Serializable>(SerializableFactory<T> factory) {
    _factories[factory.typeName] = factory;
  }
  
  /// 获取序列化工厂
  SerializableFactory<T>? getFactory<T extends Serializable>(String typeName) {
    return _factories[typeName] as SerializableFactory<T>?;
  }
  
  /// 检查类型是否已注册
  bool isRegistered(String typeName) {
    return _factories.containsKey(typeName);
  }
  
  /// 获取所有注册的类型
  List<String> get registeredTypes => _factories.keys.toList();
}