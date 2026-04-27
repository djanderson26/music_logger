import 'package:flutter/material.dart';

/// Review screen — placeholder implementation.
/// TODO: Implement in the relevant milestone.
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({
    this.targetId,
    this.targetType,
    super.key,
  });

  final String? targetId;
  final String? targetType;

  @override
  Widget build(BuildContext context) {
    final displayTarget = targetType ?? 'unknown';
    return Scaffold(
      appBar: AppBar(title: const Text('Write Review')),
      body: Center(
        child: Text('Review for $displayTarget — $targetId (coming soon)'),
      ),
    );
  }
}
