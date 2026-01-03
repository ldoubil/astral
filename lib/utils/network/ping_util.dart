import 'dart:io';
import 'dart:async';

class PingUtil {
  static Future<int?> ping(String server) async {
    try {
      final parts = server.split(':');
      final hostname = parts[0];
      final port = parts.length > 1 ? int.parse(parts[1]) : 80;

      Socket? socket;
      final stopwatch = Stopwatch();

      try {
        stopwatch.start();
        socket = await Socket.connect(
          hostname,
          port,
          timeout: const Duration(seconds: 5),
        );
        stopwatch.stop();
        final ms = stopwatch.elapsedMilliseconds;
        return ms > 800 ? null : ms;
      } on SocketException {
        return null;
      } finally {
        socket?.destroy();
      }
    } catch (e, stackTrace) {
      // 记录错误日志
      return null;
    }
  }
}
