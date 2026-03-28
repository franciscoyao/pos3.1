import 'package:flutter/material.dart';
import '../shared/models.dart';
import '../shared/printer_screen.dart';

class KioskScreen extends StatelessWidget {
  final User user;

  const KioskScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiosk Display'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrinterScreen())),
          ),
        ],
      ),
      body: const Center(child: Text('Kiosk Screen under construction')),
    );
  }
}
