import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  bool _selectMode = false;
  List<Map<String, dynamic>> _selectedCards = [];

  void toggleSelectMode() {
    setState(() {
      _selectMode = !_selectMode;
      if (!_selectMode) {
        // clear selection
        _selectedCards.clear();
      }
    });
  }

  void refresh() {
    print('test');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final collectionAsync = ref.watch(collectionProvider);
    final totalValue = ref.watch(portfolioValueProvider);


    // Find the deck by id
    final deckId = ref.read(decksProvider.notifier).curDeck;
  final decks = ref.watch(decksProvider);
  final deck = decks.maybeWhen(
    data: (decksList) => decksList.firstWhere(
      (d) => d.id == deckId,
      orElse: () => DeckItem(id: '', name: 'All cards', cards: []),
    ),
    orElse: () => DeckItem(id: '', name: 'All cards', cards: []),
  );



    final allCards = deckId != "" 
      ? deck.cards 
      : ref.watch(collectionProvider).value ?? [];

    final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final filteredCards = allCards.where((card) {
    return query.isEmpty ||
        card['name'].toLowerCase().contains(query);
  }).toList();

  final totalCards = filteredCards.length;


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: false,
        title: 
        !_selectMode
        ? const Text(
            'My Collection',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          )
        : Text(
            "${_selectedCards.length} selected",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: 
            !_selectMode
            // Decks Button (matches height and holo style)
            ? TextButton(
                onPressed: () {
                  context.push('/decks');
                },
                child: Text(
                  'Decks',
                  style: TextStyle(
                    color: Colors.amberAccent, // Holo color match
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            // cancel if in selection mode
            : IconButton(
                onPressed: () {
                  toggleSelectMode();
                },
                icon: const Icon(Icons.close, size: 20),
              ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              color: Colors.black,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search, filter, and view mode
                  // CollectionsPage snippet
                  Row(
                    children: [
                      // Search Bar
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
                              contentPadding: const EdgeInsets.symmetric(),
                            ),
                          ),
                        ),
                      ),
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
                  const SizedBox(height: 12),

                  // current deck and qty
                  Row(
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
                  ),

                  // Divider for separation
                  Divider(color: Colors.grey.shade800, thickness: 1),
                ],
              ),
            ),

            // Card collection
          Expanded(
            child: _buildCollectionList(filteredCards, deckId),
          ),

          ],
        ),
      ),
      floatingActionButton: 
      !_selectMode 
      // Add new card to collection
      ? FloatingActionButton.extended(
          onPressed: () {
            context.go('/search');
          },
          label: const Text('New Card'),
          backgroundColor: Colors.grey.shade900,
          foregroundColor: Colors.cyanAccent,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.grey.shade800,
              width: 1,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          icon: Icon(Icons.add),
        )
      : _selectedCards.isEmpty
      ? null
      // Multi-select options
      : SpeedDial(
          label: const Text('Options'),
          backgroundColor: Colors.grey.shade900,
          foregroundColor: Colors.tealAccent,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.grey.shade800,
              width: 1,
              style: BorderStyle.solid
            ),
            borderRadius: BorderRadius.circular(28.0),
          ),
          overlayOpacity: 0,
          icon: Icons.add,
          children: [
            // add cards to a deck
            SpeedDialChild(
              child: const Icon(Icons.playlist_add),
              backgroundColor: Colors.grey.shade900,
              foregroundColor: Colors.amberAccent,
              label: 'Add card(s) to a deck',
              onTap: () async {
                // Retrieve current decks from the provider
                final decks = ref.read(decksProvider);
                if (decks.maybeWhen(
                  data: (decksList) => decksList.isEmpty,
                  orElse: () => false,
                )) {
                  Fluttertoast.showToast(
                    msg: "No decks available. Please create a deck first.",
                    gravity: ToastGravity.CENTER,
                    textColor: Colors.teal.shade50,
                    toastLength: Toast.LENGTH_LONG
                  );
                  return;
                }

                // Show a bottom sheet to select a deck
                final selectedDeckId = await showModalBottomSheet<String>(
                  context: context,
                  backgroundColor: Colors.grey.shade900,
                  builder: (context) {
                    final decksAsync = ref.watch(decksProvider);

                    return decksAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(child: Text('Error: $error')),
                      data: (decksList) {
                        if (decksList.isEmpty) {
                          return const Center(
                            child: Text(
                              'No decks available\nCreate one first!',
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: decksList.length,
                          itemBuilder: (context, index) {
                            final deck = decksList[index];
                            return ListTile(
                              title: Text(
                                deck.name,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                '${deck.cards.length} cards',
                                style: TextStyle(color: Colors.grey.shade400),
                              ),
                              onTap: () => Navigator.pop(context, deck.id),
                            );
                          },
                        );
                      },
                    );
                  },
                );
                // If a deck was selected, add the cards to that deck
                if (selectedDeckId != null) {
                  for (final card in _selectedCards) {
                    ref
                      .read(decksProvider.notifier)
                      .addCardToDeck(selectedDeckId, card);
                  }
                  Fluttertoast.showToast(
                    msg: "${_selectedCards.length} cards added to deck!",
                    gravity: ToastGravity.CENTER,
                    textColor: Colors.teal.shade50,
                  );
                  toggleSelectMode();
                }
              },
            ),

            // remove cards from collection
            SpeedDialChild(
              child: const Icon(Icons.delete_outline),
              backgroundColor: Colors.grey.shade900,
              foregroundColor: Colors.deepOrange,
              label: 'Remove card(s) from collection',
              onTap:
                  () => showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Colors.grey.shade900,
                        titleTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        contentTextStyle: const TextStyle(color: Colors.white),
                        title: const Text("Warning"),
                        content: const Text(
                          "Are you sure you want to remove these cards from your collection?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'No',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final collectionService = ref.read(
                                collectionServiceProvider,
                              );
                              for (final card in _selectedCards) {
                                await collectionService.removeCard(card);
                              }
                              Fluttertoast.showToast(
                                msg: "${_selectedCards.length} cards removed from collection!",
                                gravity: ToastGravity.CENTER,
                                textColor: Colors.teal.shade50,
                              );
                              toggleSelectMode();
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Yes',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
            ),
          ],
        )
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
            padding: const EdgeInsets.all(5),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.55, // Adjusted aspect ratio
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) { 
              return CardGridItem(index: index, card: cards[index],
                callbackFunction: toggleSelectMode, selectMode: _selectMode, selectedCards: _selectedCards,
                  extraCallback: refresh);
            }
          )
        : ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              return CardListItem(index: index, card: cards[index], 
                callbackFunction: toggleSelectMode, selectMode: _selectMode, selectedCards: _selectedCards, 
                  extraCallback: refresh);
            },
          );
  }
}

