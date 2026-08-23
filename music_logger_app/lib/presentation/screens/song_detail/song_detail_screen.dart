import 'package:flutter/material.dart';

/// SongDetail screen — placeholder implementation.
/// TODO: Implement in the relevant milestone.
class SongDetailScreen extends StatelessWidget {
  const SongDetailScreen({
    required this.songId,
    super.key,
  });

  final String songId;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Song')),
      body: Center(
        child: Text('Song Detail — $songId (coming soon)'),
      ),
    );
}
