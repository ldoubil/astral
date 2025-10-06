import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:astral/data/storage/typed_storage.dart';
import 'package:astral/state/typed_persistent_signal.dart';
import 'package:astral/data/models/server_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('TypedStorage 测试', () {
    late TypedStorage storage;

    setUp(() {
      storage = TypedStorage();
    });

    group('基本类型存储', () {
      test('应该能够存储和检索字符串', () async {
        await storage.setValue('test', 'test_string', 'Hello World');
        final result = await storage.getValue<String>('test', 'test_string');
        expect(result, 'Hello World');
      });

      test('应该能够存储和检索整数', () async {
        await storage.setValue('test', 'test_int', 42);
        final result = await storage.getValue<int>('test', 'test_int');
        expect(result, 42);
      });

      test('应该能够存储和检索布尔值', () async {
        await storage.setValue('test', 'test_bool', true);
        final result = await storage.getValue<bool>('test', 'test_bool');
        expect(result, true);
      });

      test('应该能够存储和检索双精度浮点数', () async {
        await storage.setValue('test', 'test_double', 3.14);
        final result = await storage.getValue<double>('test', 'test_double');
        expect(result, 3.14);
      });

      test('应该返回默认值当键不存在时', () async {
        final result = await storage.getValue<String>('test', 'non_existent', 'default');
        expect(result, 'default');
      });
    });

    group('列表存储', () {
      test('应该能够存储和检索字符串列表', () async {
        final testList = ['item1', 'item2', 'item3'];
        await storage.setList('test', 'test_list', testList);
        final result = await storage.getList<String>('test', 'test_list');
        expect(result, testList);
      });
    });

    group('Map 存储', () {
      test('应该能够存储和检索字符串 Map', () async {
        final testMap = {'key1': 'value1', 'key2': 'value2'};
        await storage.setMap('test', 'test_map', testMap);
        final result = await storage.getMap<String, String>('test', 'test_map');
        expect(result, testMap);
      });
    });

    group('可序列化对象存储', () {
      test('应该能够存储和检索 ServerModel', () async {
        final server = ServerModel(
          id: 1,
          name: 'Test Server',
          url: 'https://test.com',
          enable: true,
          protocol: ProtocolType.https,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await storage.setObject('test', 'test_server', server);
        final retrievedServer = await storage.getObject<ServerModel>(
          'test',
          'test_server',
          ServerModel.fromJson,
        );

        expect(retrievedServer?.name, server.name);
        expect(retrievedServer?.url, server.url);
        expect(retrievedServer?.enable, server.enable);
      });
    });
  });

  group('TypedPersistentSignal 测试', () {
    group('基本类型信号', () {
      test('应该能够创建和使用字符串信号', () {
        final signal = typedPersistentString(key: 'test_signal', initialValue: 'initial');
        expect(signal.value, 'initial');
        
        signal.value = 'updated';
        expect(signal.value, 'updated');
      });

      test('应该能够创建和使用整数信号', () {
        final signal = typedPersistentInt(key: 'test_int_signal', initialValue: 0);
        expect(signal.value, 0);
        
        signal.value = 42;
        expect(signal.value, 42);
      });

      test('应该能够创建和使用布尔信号', () {
        final signal = typedPersistentBool(key: 'test_bool_signal', initialValue: false);
        expect(signal.value, false);
        
        signal.value = true;
        expect(signal.value, true);
      });

      test('应该能够创建和使用双精度信号', () {
        final signal = typedPersistentDouble(key: 'test_double_signal', initialValue: 0.0);
        expect(signal.value, 0.0);
        
        signal.value = 3.14;
        expect(signal.value, 3.14);
      });

      test('应该能够创建和使用列表信号', () {
        final signal = typedPersistentList<String>(key: 'test_list_signal', initialValue: []);
        expect(signal.value, []);
        
        signal.value = ['item1', 'item2'];
        expect(signal.value, ['item1', 'item2']);
      });

      test('应该能够创建和使用 Map 信号', () {
        final signal = typedPersistentMap<String, int>(key: 'test_map_signal', initialValue: {});
        expect(signal.value, {});
        
        signal.value = {'key1': 1, 'key2': 2};
        expect(signal.value, {'key1': 1, 'key2': 2});
      });
    });

    group('TypedPersistentListSignal 操作', () {
      test('应该能够添加和删除项目', () async {
        final signal = TypedPersistentListSignal<ServerModel>('test_server_list', [], boxName: 'test');
        
        final server1 = ServerModel(
          id: 1,
          name: 'Test Server 1',
          url: 'https://test1.com',
          enable: true,
          protocol: ProtocolType.https,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        signal.add(server1);
        expect(signal.value.length, 1);
        expect(signal.value.first.name, 'Test Server 1');
        
        signal.remove(server1);
        expect(signal.value.length, 0);
      });
      
      test('应该能够清空列表', () async {
        final signal = TypedPersistentListSignal<String>('test_string_list', ['a', 'b', 'c'], boxName: 'test');
        
        expect(signal.value.length, 3);
        signal.clear();
        expect(signal.value.length, 0);
      });
    });

    group('TypedPersistentMapSignal 操作', () {
      test('应该能够设置和获取键值对', () async {
        final signal = TypedPersistentMapSignal<String, String>('test_map_ops', {}, boxName: 'test');
        
        signal.put('key1', 'value1');
        expect(signal.value['key1'], 'value1');
        
        signal.put('key2', 'value2');
        signal.put('key3', 'value3');
        expect(signal.value.length, 3);
        
        signal.removeKey('key2');
        expect(signal.value.length, 2);
        expect(signal.value.containsKey('key2'), false);
        
        signal.clear();
        expect(signal.value.length, 0);
      });
      
      test('应该能够处理复杂类型的 Map', () async {
        final signal = TypedPersistentMapSignal<String, List<String>>('test_complex_map', {}, boxName: 'test');
        
        signal.put('tags', ['tag1', 'tag2']);
        expect(signal.value['tags'], ['tag1', 'tag2']);
        
        // 手动更新列表
        final currentTags = signal.value['tags'] ?? [];
        signal.put('tags', [...currentTags, 'tag3']);
        expect(signal.value['tags'], ['tag1', 'tag2', 'tag3']);
      });
    });
  });
}