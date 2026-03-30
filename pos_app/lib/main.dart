import 'package:flutter/material.dart';
import 'package:pos_server_client/pos_server_client.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

late Client client;

/// Initialize or re-initialize the Serverpod client
Future<void> initClient() async {
  final prefs = await SharedPreferences.getInstance();
  final serverIp = prefs.getString('server_ip') ?? '192.168.1.126';

  client = Client('http://$serverIp:8080/')
    ..connectivityMonitor = FlutterConnectivityMonitor();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
