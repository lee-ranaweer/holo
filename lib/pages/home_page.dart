import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final currentUser = ref.watch(authStateProvider).value!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          userProfile.when(
            data: (data) => 'Welcome, ${data?['username'] ?? currentUser.email!}',
            loading: () => 'Welcome, ${currentUser.email ?? 'Loading...'}',
            error: (_, __) => 'Welcome, ${currentUser.email ?? 'Error'}',
          ),
        ),
      ),
    );
  }
}
