import 'package:flutter_test/flutter_test.dart';
import 'package:astral/data/storage/typed_storage.dart';
import 'package:astral/data/models/server_model.dart';

void main() {
  group('TypedStorage 单元测试', () {
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

      test('应该能够存储和检索整数列表', () async {
        final testList = [1, 2, 3, 4, 5];
        await storage.setList('test', 'test_int_list', testList);
        final result = await storage.getList<int>('test', 'test_int_list');
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

      test('应该能够存储和检索混合类型 Map', () async {
        final testMap = {'string': 'value', 'int': 42, 'bool': true};
        await storage.setMap('test', 'test_mixed_map', testMap);
        final result = await storage.getMap<String, dynamic>('test', 'test_mixed_map');
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
        expect(retrievedServer?.protocol, server.protocol);
      });

      test('应该能够存储和检索 ServerModel 列表', () async {
        final servers = [
          ServerModel(
            id: 1,
            name: 'Server 1',
            url: 'https://server1.com',
            enable: true,
            protocol: ProtocolType.https,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          ServerModel(
            id: 2,
            name: 'Server 2',
            url: 'https://server2.com',
            enable: false,
            protocol: ProtocolType.tcp,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        await storage.setList('test', 'test_servers', servers);
        final retrievedServers = await storage.getList<ServerModel>(
          'test',
          'test_servers',
          fromJson: ServerModel.fromJson,
        );

        expect(retrievedServers.length, 2);
        expect(retrievedServers[0].name, 'Server 1');
        expect(retrievedServers[1].name, 'Server 2');
        expect(retrievedServers[0].enable, true);
        expect(retrievedServers[1].enable, false);
      });
    });

    group('错误处理', () {
      test('应该处理空列表', () async {
        await storage.setList<String>('test', 'empty_list', []);
        final result = await storage.getList<String>('test', 'empty_list');
        expect(result, []);
      });

      test('应该处理空 Map', () async {
        await storage.setMap<String, String>('test', 'empty_map', {});
        final result = await storage.getMap<String, String>('test', 'empty_map');
        expect(result, {});
      });

      test('应该返回 null 当对象不存在时', () async {
        final result = await storage.getObject<ServerModel>(
          'test',
          'non_existent_server',
          ServerModel.fromJson,
        );
        expect(result, isNull);
      });
    });
  });
}