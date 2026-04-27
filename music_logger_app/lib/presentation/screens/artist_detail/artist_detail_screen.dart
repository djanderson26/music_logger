import 'package:flutter/material.dart';

/// ArtistDetail screen — placeholder implementation.
/// TODO: Implement in the relevant milestone.
class ArtistDetailScreen extends StatelessWidget {
  const ArtistDetailScreen({
    required this.artistId,
    super.key,
  });

  final String artistId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artist')),
      body: Center(
        child: Text('Artist Detail — $artistId (coming soon)'),
      ),
    );
  }
}
