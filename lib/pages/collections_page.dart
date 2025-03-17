import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:holo/pages/decks_page.dart';
import 'package:holo/pages/details_page.dart';
import '../services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/card_widgets.dart';

class CollectionsPage extends ConsumerWidget  {
  const CollectionsPage({super.key}); 

  void _showRarityFilter(BuildContext context, WidgetRef ref) {
    const rarityOptions = [
      'Unknown',
      'Common',
      'Uncommon',
      'Rare',
      'Rare Holo',
      'Promo',
      'Ultra Rare',
      'Hyper Rare',
      'Double Rare',
      'Secret Rare',
    ];

    final currentSelection = ref.read(selectedRaritiesProvider);
    var tempSelection = Set<String>.from(currentSelection);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Filter by Rarity",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ...rarityOptions.map((rarity) {
                      return CheckboxListTile(
                        title: Text(
                          rarity,
                          style: TextStyle(color: Colors.white),
                        ),
                        value: tempSelection.contains(rarity),
                        activeColor: Colors.green,
                        checkColor: Colors.white,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              tempSelection.add(rarity);
                            } else {
                              tempSelection.remove(rarity);
                            }
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            tempSelection.clear();
                            ref.read(selectedRaritiesProvider.notifier).state = tempSelection;
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Clear',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(selectedRaritiesProvider.notifier).state = tempSelection;
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }



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
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
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
                  const SizedBox(width: 8),
                  // Filter Button
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: GestureDetector(
                      onTap: () => _showRarityFilter(context, ref),
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
                    )
                  ),
                ],
              ),
            ),

            // current deck
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Showing: All cards ($cardqty)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
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
}
