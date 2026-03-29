import 'package:flutter/material.dart';

class CheckoutHistoryView extends StatelessWidget {
  const CheckoutHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Checkout History\n(Serverpod client – coming soon)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
