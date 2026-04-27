import 'package:flutter/material.dart';

/// AlbumDetail screen — placeholder implementation.
/// TODO: Implement in the relevant milestone.
class AlbumDetailScreen extends StatelessWidget {
  const AlbumDetailScreen({
    required this.albumId,
    super.key,
  });

  final String albumId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Album')),
      body: Center(
        child: Text('Album Detail — $albumId (coming soon)'),
      ),
    );
  }
}
