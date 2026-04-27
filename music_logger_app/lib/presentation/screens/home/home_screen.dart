import 'package:flutter/material.dart';

/// Home screen — placeholder implementation.
/// TODO: Implement in the relevant milestone.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Home — coming soon')),
    );
  }
}
