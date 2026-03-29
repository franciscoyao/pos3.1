import 'package:serverpod/serverpod.dart';
import 'generated/protocol.dart';

/// Manages real-time event broadcasting to all connected streaming clients.
class EventService {
  static const String _channel = 'pos_events';

  static Future<void> broadcast(Session session, String eventType) async {
    await session.messages.postMessage(
      _channel,
      PosEvent(eventType: eventType),
    );
  }
}
