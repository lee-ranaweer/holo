import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavBar extends StatelessWidget {
  final Widget child;

  const NavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade800, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _getSelectedIndex(context),
          backgroundColor: Colors.black, // Sleek black background
          selectedItemColor: Colors.white, // Highlighted tab color
          unselectedItemColor:
              Colors.grey.shade600, // Subtle grey for unselected tabs
          elevation: 0, // No shadow for clean design
          showUnselectedLabels: false, // Hide labels for unselected tabs
          showSelectedLabels: true, // Show labels only for selected tabs

          onTap: (index) {
            switch (index) {
              case 0:
                context.go('/');
                break;
              case 1:
                context.go('/collections');
                break;
              case 2:
                context.go('/search');
                break;
              case 3:
                context.go('/notifications');
                break;
              case 4:
                context.go('/account');
                break;
            }
          },

          items: [
            _buildNavItem(Icons.home, 'Home'),
            _buildNavItem(Icons.collections, 'Collections'),
            _buildNavItem(Icons.search, 'Search'),
            _buildNavItem(Icons.notifications, 'Alerts'),
            _buildNavItem(Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }

  // Custom function to build navigation items with spacing & modern styling
  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 4.0), // Subtle spacing
        child: Icon(icon, size: 24),
      ),
      label: label,
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location == '/') return 0;
    if (location == '/collections') return 1;
    if (location == '/search') return 2;
    if (location == '/notifications') return 3;
    if (location == '/account') return 4;
    return 0;
  }
}
