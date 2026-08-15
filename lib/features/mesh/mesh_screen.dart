import 'package:flutter/material.dart';

class MeshScreen extends StatelessWidget {
  const MeshScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mesh Network')),
      body: const Center(child: Text('Mesh visualization and status')),
    );
  }
}
