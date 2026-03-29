import 'package:flutter/material.dart';

class NewOrderView extends StatelessWidget {
  const NewOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'New Order\n(Serverpod client – coming soon)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
