import 'package:go_router/go_router.dart';
import 'widgets/navbar.dart';
import 'pages/home_page.dart';
import 'pages/collections_page.dart';
import 'pages/search_page.dart';
import 'pages/notifications_page.dart';
import 'pages/account_page.dart';

final GoRouter router = GoRouter(
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
