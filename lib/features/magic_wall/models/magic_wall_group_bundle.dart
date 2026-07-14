import 'package:astral/core/models/magic_wall_model.dart';

class MagicWallGroupBundle {
  MagicWallGroupBundle({required this.group, required this.rules});

  final MagicWallGroupModel group;
  final List<MagicWallRuleModel> rules;
}
