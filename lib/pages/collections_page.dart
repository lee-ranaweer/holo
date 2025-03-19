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
    final filteredCollectionAsync = ref.watch(filteredCollectionProvider);
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
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      onSubmitted: (value) {
                        ref.read(searchQueryProvider.notifier).state = value;
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade900,
                        hintText: 'Search your collection...',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                      ),
                    ),
                  ),
                  // Filter Button
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Implement collection filter
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade900,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.filter_alt_outlined,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Plus button for adding cards
                  // GestureDetector(
                  //   onTap: () {
                  //     context.go('/search');
                  //   },
                  //   child: Container(
                  //     padding: const EdgeInsets.all(14.0),
                  //     decoration: BoxDecoration(
                  //       shape: BoxShape.circle,
                  //       color: Colors.white,
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.white.withOpacity(0.2),
                  //           blurRadius: 10,
                  //           spreadRadius: 1,
                  //         ),
                  //       ],
                  //     ),
                  //     child: const Icon(
                  //       Icons.add,
                  //       size: 28,
                  //       color: Colors.black,
                  //     ),
                  //   ),
                  // ),
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
              child: filteredCollectionAsync.when(
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
