import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:holo/pages/decks_page.dart';
import 'package:holo/pages/details_page.dart';
import '../services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/card_widgets.dart';

class CollectionsPage extends ConsumerStatefulWidget  {
  const CollectionsPage({super.key}); 

  @override
  CollectionsPageState createState() => CollectionsPageState();
}

class CollectionsPageState extends ConsumerState<CollectionsPage> {
  bool _gridMode = false;

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
  Widget build(BuildContext context) {
    final collectionAsync = ref.watch(collectionProvider);
    final filteredCollectionAsync = ref.watch(filteredCollectionProvider);
    final totalValue = ref.watch(portfolioValueProvider);
    final cardqty = ref.watch(collectionProvider).value?.length;

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
            // Search, filter, and view mode
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  // Search Bar
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
                  // Filter
                  IconButton(
                    onPressed: () {
                      _showRarityFilter(context, ref);
                    },
                    icon: const Icon(Icons.filter_alt_outlined, size: 20),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  // List/Grid mode
                  _gridMode 
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _gridMode = false;
                        });
                      },
                      icon: const Icon(Icons.list, size: 20),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                  :
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _gridMode = true;
                      });
                    },
                    icon: const Icon(Icons.grid_on, size: 20),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                ],
              ),
            ),

            // current deck and qty
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
      // Add new card to collection
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/search');
        },
        label: const Text('New Card'),
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.teal.shade200,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.grey.shade800,
            width: 1,
            style: BorderStyle.solid
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        icon: Icon(Icons.add),
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

    return _gridMode 
    ? GridView.builder(
        padding: const EdgeInsets.all(3),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.55, // Adjusted aspect ratio
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) => CardGridItem(card: cards[index]),
      )
      :
      ListView.builder(
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return _buildCollectionCard(context, card);
        }
      );
  }

  Widget _buildCollectionCard(BuildContext context, Map<String, dynamic> card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        leading: Image.network(card['images']['small'], width: 60, height: 60),
        title: Text(
          card['name'],
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          card['set']['name'],
          style: TextStyle(color: Colors.grey.shade500),
        ),
        trailing: Text(
          '\$${card['price']}',
          style: const TextStyle(
            color: Colors.green,
            fontSize: 16,
            fontWeight: FontWeight.bold
          ),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsPage(card: card)
          ),
        ),
      ),
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
