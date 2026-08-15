import 'package:flutter/material.dart';

class GatewayScreen extends StatelessWidget {
  const GatewayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gateway')),
      body: const Center(child: Text('Gateway status and sync')),
    );
  }
}
