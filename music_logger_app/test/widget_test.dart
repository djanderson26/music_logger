import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:music_logger_app/main.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MusicLoggerApp(),
      ),
    );

    // Verify that a MaterialApp is present in the widget tree.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
