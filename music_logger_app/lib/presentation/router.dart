import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/home/home_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/catalog/catalog_screen.dart';
import 'screens/lists/lists_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/album_detail/album_detail_screen.dart';
import 'screens/artist_detail/artist_detail_screen.dart';
import 'screens/song_detail/song_detail_screen.dart';
import 'screens/list_detail/list_detail_screen.dart';
import 'screens/review/review_screen.dart';
import 'widgets/common/scaffold_with_nav_bar.dart';

/// Top-level router configuration using go_router.
///
/// Routes:
///   /home       → HomeScreen (with nav bar)
///   /search     → SearchScreen (with nav bar)
///   /catalog    → CatalogScreen (with nav bar)
///   /lists      → ListsScreen (with nav bar)
///   /profile    → ProfileScreen (with nav bar)
///   /album/:id  → AlbumDetailScreen (full screen)
///   /artist/:id → ArtistDetailScreen (full screen)
///   /song/:id   → SongDetailScreen (full screen)
///   /review     → ReviewScreen (full screen, with query params: targetId, targetType)
///   /list/:id   → ListDetailScreen (full screen)
final appRouter = GoRouter(
  initialLocation: '/home',
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Route not found: ${state.uri}'),
    ),
  ),
  routes: [
    ShellRoute(
      builder: (context, state, child) => ScaffoldWithNavBar(
          location: state.uri.toString(),
          child: child,
        ),
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/search',
          name: 'search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/catalog',
          name: 'catalog',
          builder: (context, state) => const CatalogScreen(),
        ),
        GoRoute(
          path: '/lists',
          name: 'lists',
          builder: (context, state) => const ListsScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    // Full-screen detail routes (no nav bar)
    GoRoute(
      path: '/album/:id',
      name: 'album_detail',
      builder: (context, state) {
        final albumId = state.pathParameters['id']!;
        return AlbumDetailScreen(albumId: albumId);
      },
    ),
    GoRoute(
      path: '/artist/:id',
      name: 'artist_detail',
      builder: (context, state) {
        final artistId = state.pathParameters['id']!;
        return ArtistDetailScreen(artistId: artistId);
      },
    ),
    GoRoute(
      path: '/song/:id',
      name: 'song_detail',
      builder: (context, state) {
        final songId = state.pathParameters['id']!;
        return SongDetailScreen(songId: songId);
      },
    ),
    GoRoute(
      path: '/review',
      name: 'review',
      builder: (context, state) {
        final targetId = state.uri.queryParameters['targetId'];
        final targetType = state.uri.queryParameters['targetType'];
        return ReviewScreen(
          targetId: targetId,
          targetType: targetType,
        );
      },
    ),
    GoRoute(
      path: '/list/:id',
      name: 'list_detail',
      builder: (context, state) {
        final listId = state.pathParameters['id']!;
        return ListDetailScreen(listId: listId);
      },
    ),
  ],
);
