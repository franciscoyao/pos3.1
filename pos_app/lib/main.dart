import 'package:flutter/material.dart';
import 'package:pos_server_client/pos_server_client.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'login_screen.dart';

late final Client client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  client = Client('http://localhost:8080/')
    ..connectivityMonitor = FlutterConnectivityMonitor();

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
