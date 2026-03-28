import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  socket_io.Socket? _socket;

  // Event controllers
  final _orderCreatedController = StreamController<void>.broadcast();
  final _orderUpdatedController = StreamController<void>.broadcast();
  final _tableUpdatedController = StreamController<void>.broadcast();
  final _productUpdatedController = StreamController<void>.broadcast();
  final _checkoutCompletedController = StreamController<void>.broadcast();

  // Streams
  Stream<void> get onOrderCreated => _orderCreatedController.stream;
  Stream<void> get onOrderUpdated => _orderUpdatedController.stream;
  Stream<void> get onTableUpdated => _tableUpdatedController.stream;
  Stream<void> get onProductUpdated => _productUpdatedController.stream;
  Stream<void> get onCheckoutCompleted => _checkoutCompletedController.stream;

  Future<void> init() async {
    if (_socket != null && _socket!.connected) return;

    final prefs = await SharedPreferences.getInstance();
    final serverIp = prefs.getString('server_ip') ?? '127.0.0.1';
    final serverUrl = 'http://$serverIp:3000';

    _socket = socket_io.io(
        serverUrl,
        socket_io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());

    _socket!.onConnect((_) {
      debugPrint('Socket.io connected to $serverUrl');
    });

    _socket!.onDisconnect((_) {
      debugPrint('Socket.io disconnected');
    });

    // Subscriptions
    _socket!.on('order_created', (_) => _orderCreatedController.add(null));
    _socket!.on('order_updated', (_) => _orderUpdatedController.add(null));
    _socket!.on('table_updated', (_) => _tableUpdatedController.add(null));
    _socket!.on('product_updated', (_) => _productUpdatedController.add(null));
    _socket!.on('checkout_completed', (_) => _checkoutCompletedController.add(null));

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
