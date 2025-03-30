import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:holo/pages/decks_page.dart';
import 'package:holo/pages/details_page.dart';
import 'package:holo/providers/decks_provider.dart';
import 'package:holo/widgets/card_list.dart';
import 'package:holo/widgets/collection_filter.dart';
import '../services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/card_grid.dart';

class CollectionsPage extends ConsumerStatefulWidget {
  const CollectionsPage({super.key});

  @override
  CollectionsPageState createState() => CollectionsPageState();
}

class CollectionsPageState extends ConsumerState<CollectionsPage> {
  bool _gridMode = false;

  @override
  Widget build(BuildContext context) {
    final collectionAsync = ref.watch(collectionProvider);
    final filteredCollectionAsync = ref.watch(filteredCollectionProvider);
    final totalValue = ref.watch(portfolioValueProvider);

    // Find the deck by id
    final deckId = ref.read(decksProvider.notifier).curDeck;
    final decks = ref.watch(decksProvider);
    final deck = decks.firstWhere(
      (d) => d.id == deckId,
      orElse: () => DeckItem(id: '', name: 'All cards'),
    );
    final totalCards = 
      deckId != "" ? deck.cards.length : ref.watch(collectionProvider).value?.length;


    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    "My Collection",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Spacer(),
                  // Decks Button (matches height and holo style)
                  SizedBox(
                    height: 34,
                    child: TextButton(
                      onPressed: () {
                        context.push('/decks');
                      },
                      style: TextButton.styleFrom(
                        // backgroundColor: Colors.grey.shade900,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          // side: BorderSide(
                          //   color: Colors.grey.shade800,
                          //   width: 1,
                          // ),
                        ),
                      ),
                      child: Text(
                        'Decks',
                        style: TextStyle(
                          color: Colors.teal.shade200, // Holo color match
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Search, filter, and view mode
            // CollectionsPage snippet
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  // Search Bar (shrink a little to make room for Decks button)
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 40, // Set consistent height
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
                            vertical: 0.0,
                            horizontal: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // const SizedBox(width: 8),
                  const SizedBox(width: 8),

                  // Filter icon
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return CollectionFilter();
                        },
                      );
                    },
                    icon: const Icon(Icons.filter_alt_outlined, size: 20),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),

                  // List/Grid icon
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
                      : IconButton(
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
                      ),
                ],
              ),
            ),

            // current deck and qty
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    'Showing: ${deck.name} ($totalCards)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  if (deckId != "")
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          ref.read(decksProvider.notifier).curDeck = "";
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: const Icon(Icons.close, size: 16),
                      )
                    ),
                ],
              )
            ),

            // Divider for separation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(color: Colors.grey.shade800, thickness: 1),
            ),

            // Card collection
            Expanded(
              // fix this later
              // child: filteredCollectionAsync.when(
              //   loading: () => const Center(child: CircularProgressIndicator()),
              //   error: (error, _) => Center(child: Text('Error: $error')),
              //   data: (cards) => _buildCollectionList(cards),
              // ),
              child: _buildCollectionList(
                deckId != "" 
                  ? deck.cards
                  : ref.watch(collectionProvider).value!
                  , deckId
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
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        icon: Icon(Icons.add),
      ),
    );
  }

  Widget _buildCollectionList(List<Map<String, dynamic>> cards, final deckId) {
    if (cards.isEmpty) {
      return Center(
        child: Text(
          deckId != "" ? 'No cards in deck' : 'No cards in collection',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
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
        : ListView.builder(
          itemCount: cards.length,
          itemBuilder: (context, index) {
            return CardListItem(card: cards[index]);
          },
        );
  }
}
