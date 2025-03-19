import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/navbar.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/signup_page.dart';
import '../pages/collections_page.dart';
import '../pages/search_page.dart';
import '../pages/notifications_page.dart';
import '../pages/account_page.dart';
import '../services/auth_service.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.uri.path == '/login';
      final isSigningUp = state.uri.path == '/signup';

      // If not logged in and trying to access protected route
      if (!isLoggedIn && !isLoggingIn && !isSigningUp) {
        return '/login';
      }

      // If logged in but trying to access auth routes
      if (isLoggedIn && (isLoggingIn || isSigningUp)) {
        return '/';
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => SignUpPage(),
      ),
      
      // Protected routes with navbar
      ShellRoute(
        builder: (context, state, child) => NavBar(child: child),
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
});