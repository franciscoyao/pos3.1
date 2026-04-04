import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pos_server_client/pos_server_client.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

late Client client;
late StreamController<PosEvent> posEventStreamController;

/// Initialize or re-initialize the Serverpod client
Future<void> initClient() async {
  final prefs = await SharedPreferences.getInstance();
  final serverIp = prefs.getString('server_ip') ?? '192.168.1.141';

  // Normalize 'localhost' for mobile/emulator access if needed
  String baseUrl;
  if (serverIp.toLowerCase() == 'localhost' || serverIp == '127.0.0.1') {
    baseUrl = 'http://localhost:8080/';
  } else {
    baseUrl = 'http://$serverIp:8080/';
  }

  client = Client(baseUrl)..connectivityMonitor = FlutterConnectivityMonitor();

  // Setup global event stream
  posEventStreamController = StreamController<PosEvent>.broadcast();
  _startEventSubscription();
}

void _startEventSubscription() {
  client.events.subscribe().listen(
    (event) {
      posEventStreamController.add(event);
    },
    onError: (e) {
      debugPrint('Event stream error: $e');
      // Reconnect after delay
      Future.delayed(
        const Duration(seconds: 5),
        () => _startEventSubscription(),
      );
    },
    cancelOnError: false,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clean up old server IPs if present
  final prefs = await SharedPreferences.getInstance();
  final currentIp = prefs.getString('server_ip');
  if (currentIp == '192.168.1.136' || currentIp == '192.168.1.162') {
    await prefs.setString('server_ip', '192.168.1.140');
  }

  await initClient();

  runApp(const POSApp());
}

class POSApp extends StatelessWidget {
  const POSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE63946),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE63946),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system, // Dynamic dark mode
      home: const LoginScreen(),
    );
  }
}
