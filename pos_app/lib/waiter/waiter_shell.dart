import 'package:flutter/material.dart';

class WaiterShell extends StatelessWidget {
  final String role;
  const WaiterShell({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Waiter Shell\n(Serverpod client – coming soon)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
