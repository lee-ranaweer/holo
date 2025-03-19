import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/card_widgets.dart';

class CollectionsPage extends ConsumerWidget  {
  const CollectionsPage({super.key}); 

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionAsync = ref.watch(collectionProvider);
    final totalValue = ref.watch(portfolioValueProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                "My Collection",
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // Navbar-like row with 3 buttons: Filter, Rec, and a circular + button.
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  _buildButton(context, 'Filter', Icons.filter_list, () {
                    // TODO: Add filter functionality.
                  }),
                  // SizedBox(width: 20),
                  // _buildButton(context, 'Market', Icons.trending_up, () {
                  //   // TODO: Add rec functionality.
                  // }),
                  Spacer(),
                  // Plus button for adding cards
                  GestureDetector(
                    onTap: () {
                      context.go('/search');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 28,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider for separation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(color: Colors.grey.shade800, thickness: 1),
            ),

            // Empty collection placeholder
            Expanded(
              child: collectionAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
                data: (cards) => _buildCollectionList(cards),
              ),
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildCollectionList(List<Map<String, dynamic>> cards) {
    if (cards.isEmpty) {
      return Center(
        child: Text(
          'No cards added yet.',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 16,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(3),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.55, // Adjusted aspect ratio
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => CardListItem(card: cards[index]),
    );
  }

  // Button styling function for "Filter" and "Rec"
  Widget _buildButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade800, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
