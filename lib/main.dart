import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext content) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Navbar'
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return NavBar(child: child);
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => HomePage()),
        GoRoute(path: '/collections', builder: (context, state) => CollectionsPage()), 
        GoRoute(path: '/search', builder: (context, state) => SearchPage()),
        GoRoute(path: '/notifications', builder: (context, state) => NotificationsPage()),
        GoRoute(path: '/account', builder: (context, state) => AccountPage()),
      ],
    ),
  ],
);

class NavBar extends StatelessWidget {
  final Widget child;

  NavBar({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _getSelectedIndex(context),
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        
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

        // NOTE: Icons found here https://api.flutter.dev/flutter/material/Icons-class.html
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.collections), label: 'Collections'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location == '/')              return 0;
    if (location == '/collections')   return 1;
    if (location == '/search')        return 2;
    if (location == '/notifications') return 3;
    if (location == '/account')       return 4;
    return 0;
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Home Page', style: TextStyle(fontSize: 24)));
  }
}

class CollectionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Collections Page', style: TextStyle(fontSize: 24)));
  }
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Search Page', style: TextStyle(fontSize: 24)));
  }
}

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Notifications Page', style: TextStyle(fontSize: 24)));
  }
}

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Account Page', style: TextStyle(fontSize: 24)));
  }
}