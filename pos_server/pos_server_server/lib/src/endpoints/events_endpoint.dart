import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Streaming endpoint — clients subscribe here to receive real-time PosEvents.
/// The Flutter app opens a persistent stream connection and receives events
/// whenever any endpoint calls EventService.broadcast().
class EventsEndpoint extends Endpoint {
  static const String _channel = 'pos_events';

  /// Subscribe to all POS real-time events.
  Stream<PosEvent> subscribe(Session session) async* {
    final messageStream = session.messages.createStream<PosEvent>(_channel);

    await for (final event in messageStream) {
      yield event;
    }
  }
}
