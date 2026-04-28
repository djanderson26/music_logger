import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/hive_boxes.dart';
import 'core/theme/app_theme.dart';
import 'presentation/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load();

  // Initialize Hive
  await Hive.initFlutter();
  // TODO: Register Hive adapters here
  // Hive.registerAdapter(AlbumAdapter());
  await Future.wait([
    Hive.openBox(HiveBoxes.catalog),
    Hive.openBox(HiveBoxes.reviews),
    Hive.openBox(HiveBoxes.ratings),
    Hive.openBox(HiveBoxes.lists),
    Hive.openBox(HiveBoxes.favorites),
    Hive.openBox(HiveBoxes.settings),
  ]);

  runApp(
    const ProviderScope(
      child: MusicLoggerApp(),
    ),
  );
}

class MusicLoggerApp extends ConsumerWidget {
  const MusicLoggerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Music Logger',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
