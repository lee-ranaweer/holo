import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key}); 

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final currentUser = ref.watch(authStateProvider).value!;

    return Scaffold(
        body: SafeArea(
        child: Column(
          children: [
            // top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Stack(
                children: [
                  // Title
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Sign Out Button
                  Container(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () async {
                        await ref.read(authServiceProvider).signOut();
                      },
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Profile
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.grey.shade800,
                    child: const Icon(
                      Icons.person,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    userProfile.when(
                      data: (data) => data?['username'] ?? currentUser.email!,
                      loading: () => currentUser.email ?? 'Loading...',
                      error: (_, __) => currentUser.email ?? 'Error',
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    currentUser.email!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}