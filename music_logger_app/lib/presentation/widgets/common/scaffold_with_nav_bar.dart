import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Scaffold with a 5-tab bottom navigation bar.
///
/// Used as the shell for the main app navigation.
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.child,
    required this.location,
    super.key,
  });

  final Widget child;
  final String location;

  int _getTabIndex(String location) {
    if (location.startsWith('/search')) {
      return 1;
    }
    if (location.startsWith('/catalog')) {
      return 2;
    }
    if (location.startsWith('/lists')) {
      return 3;
    }
    if (location.startsWith('/profile')) {
      return 4;
    }
    return 0; // home
  }

  void _onTabTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/search');
      case 2:
        context.go('/catalog');
      case 3:
        context.go('/lists');
      case 4:
        context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _getTabIndex(location),
        onTap: (index) => _onTabTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Catalog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Lists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
}
