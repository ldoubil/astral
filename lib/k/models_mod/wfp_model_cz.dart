import 'package:isar_community/isar.dart';
import 'package:astral/k/models/wfp_model.dart';

class WfpModelCz {
  final Isar _isar;

  WfpModelCz(this._isar) {
    init();
  }

  Future<void> init() async {}

  // 添加规则
  Future<int> addWfpModel(WfpModel model) async {
    return await _isar.writeTxn(() async {
      return await _isar.wfpModels.put(model);
    });
  }

  // 根据ID获取规则
  Future<WfpModel?> getWfpModelById(int id) async {
    return await _isar.wfpModels.get(id);
  }

  // 获取所有规则
  Future<List<WfpModel>> getAllWfpModels() async {
    return await _isar.wfpModels.where().findAll();
  }

  // 更新规则
  Future<int> updateWfpModel(WfpModel model) async {
    return await _isar.writeTxn(() async {
      return await _isar.wfpModels.put(model);
    });
  }

  // 删除规则
  Future<bool> deleteWfpModel(int id) async {
    return await _isar.writeTxn(() async {
      return await _isar.wfpModels.delete(id);
    });
  }

  // 根据名称查询规则
  Future<List<WfpModel>> getWfpModelsByName(String name) async {
    return await _isar.wfpModels.filter().nameEqualTo(name).findAll();
  }
}
