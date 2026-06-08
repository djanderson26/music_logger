import 'package:flutter/material.dart';

/// ListDetail screen — placeholder implementation.
/// TODO: Implement in the relevant milestone.
class ListDetailScreen extends StatelessWidget {
  const ListDetailScreen({
    required this.listId,
    super.key,
  });

  final String listId;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('List')),
      body: Center(
        child: Text('List Detail — $listId (coming soon)'),
      ),
    );
}
