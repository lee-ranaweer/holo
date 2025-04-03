import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../providers/watchlist_provider.dart';
import './details_page.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Retrieve user profile and auth data
    final userProfile = ref.watch(userProfileProvider);
    final currentUser = ref.watch(authStateProvider).value!;
    // Retrieve the dynamic total portfolio/card collection value
    final totalValue = ref.watch(portfolioValueProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(authServiceProvider).signOut(ref);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              visualDensity: VisualDensity.compact,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.deepPurple.shade100,
                  fontSize: 14,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // -- Top Section with Gradient Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 0,
                bottom: 24,
                left: 16,
                right: 16,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
            ),
            // -- Profile Section: Avatar, Username and Email
            Padding(
              padding: const EdgeInsets.only(
                top: 0,
                bottom: 48,
                left: 16,
                right: 16,
              ),              
              child: Column(
                children: [
                  // Avatar with white border effect
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.grey.shade800,
                      child: const Icon(
                        Icons.person,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userProfile.when(
                      data: (data) => data?['username'] ?? currentUser.email!,
                      loading: () => currentUser.email ?? 'Loading...',
                      error: (_, __) => currentUser.email ?? 'Error',
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    currentUser.email!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),

            // -- Stats Grid: Holos & Sets (only)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.star,
                    label: 'Holos',
                    value: '12', // we can replace this
                  ),
                  _buildStatItem(
                    icon: Icons.card_giftcard,
                    label: 'Sets',
                    value: '3', // also this
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // -- Account Worth: Shown in a rectangular card with an icon
            _buildWorthBox(totalValue),

            const Spacer(),

            // Footer text
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Thank you for trading with Holo!',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to display a single stat item in the grid
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
        ),
      ],
    );
  }

  // Helper widget to build a rectangular Account Worth box with an icon
  Widget _buildWorthBox(double totalValue) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon Container: Sized to match the proportion of the stats above
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.attach_money,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Text information
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Account Worth",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 4),
              Text(
                "\$${totalValue.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
