import 'package:go_router/go_router.dart';

import 'screens/home/home_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/catalog/catalog_screen.dart';
import 'screens/lists/lists_screen.dart';
import 'screens/profile/profile_screen.dart';

/// Top-level router configuration using go_router.
///
/// Routes:
///   /           → HomeScreen
///   /search     → SearchScreen
///   /catalog    → CatalogScreen
///   /lists      → ListsScreen
///   /profile    → ProfileScreen
///   /album/:id  → AlbumDetailScreen  (TODO: Milestone 3)
///   /artist/:id → ArtistDetailScreen (TODO: Milestone 3)
///   /review/:id → ReviewScreen       (TODO: Milestone 5)
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
    GoRoute(
        path: '/catalog', builder: (context, state) => const CatalogScreen()),
    GoRoute(path: '/lists', builder: (context, state) => const ListsScreen()),
    GoRoute(
        path: '/profile', builder: (context, state) => const ProfileScreen()),
  ],
);
