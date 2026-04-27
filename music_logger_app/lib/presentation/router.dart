import 'package:go_router/go_router.dart';

import 'screens/home/home_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/catalog/catalog_screen.dart';
import 'screens/lists/lists_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/album_detail/album_detail_screen.dart';
import 'screens/artist_detail/artist_detail_screen.dart';
import 'screens/review/review_screen.dart';

/// Top-level router configuration using go_router.
///
/// Routes:
///   /           → HomeScreen
///   /search     → SearchScreen
///   /catalog    → CatalogScreen
///   /lists      → ListsScreen
///   /profile    → ProfileScreen
///   /album/:id  → AlbumDetailScreen
///   /artist/:id → ArtistDetailScreen
///   /review     → ReviewScreen (with query params: targetId, targetType)
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
    GoRoute(
      path: '/album/:id',
      builder: (context, state) {
        final albumId = state.pathParameters['id']!;
        return AlbumDetailScreen(albumId: albumId);
      },
    ),
    GoRoute(
      path: '/artist/:id',
      builder: (context, state) {
        final artistId = state.pathParameters['id']!;
        return ArtistDetailScreen(artistId: artistId);
      },
    ),
    GoRoute(
      path: '/review',
      builder: (context, state) {
        final targetId = state.uri.queryParameters['targetId'];
        final targetType = state.uri.queryParameters['targetType'];
        return ReviewScreen(
          targetId: targetId,
          targetType: targetType,
        );
      },
    ),
  ],
);
