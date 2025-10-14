import 'package:astral/models/room_config.dart';
import 'package:signals_flutter/signals_flutter.dart';

class RoomState {
  Signal<List<RoomConfig>> roomConfig = Signal([]);
}