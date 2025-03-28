import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../providers/watchlist_provider.dart';
import '../providers/notifications_provider.dart'; // New import
import '../providers/decks_provider.dart'; // Import decksProvider

class DetailsPage extends ConsumerStatefulWidget {
  const DetailsPage({super.key, this.card});

  final Map<String, dynamic>? card;

  @override
  DetailsPageState createState() => DetailsPageState();
}

class DetailsPageState extends ConsumerState<DetailsPage> {
  var _cardExists = false;

  @override
  void initState() {
    super.initState();
    _getCardExists();
  }

  _getCardExists() async {
    final collectionService = ref.read(collectionServiceProvider);
    bool cardExists = await collectionService.checkCard(widget.card!['id']);
    setState(() {
      _cardExists = cardExists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Stack(
                children: [
                  // Back Button
                  Container(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => context.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 20),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                  // Title
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Card Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Card Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      widget.card!['images']['large'],
                      fit: BoxFit.contain,
                      height: 400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title & Price
                  Text(
                    widget.card!['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Set Info
                        Flexible(
                          flex: 1,
                          child: Column(
                            children: [
                              Text(
                                'Set',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.card!['set']['name'] ?? 'Unknown',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Rarity Info
                        Flexible(
                          flex: 1,
                          child: Column(
                            children: [
                              Text(
                                'Rarity',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.card!['rarity'] ?? 'Unknown',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Price Info
                        Flexible(
                          flex: 1,
                          child: Column(
                            children: [
                              Text(
                                'Value',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "\$${widget.card!['price'] != "N/A" ? widget.card!['price'] : "N/A"}",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button: SpeedDial with options
      floatingActionButton: SpeedDial(
        label:
            _cardExists ? const Text('In Collection') : const Text('Options'),
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.teal.shade50,
        overlayOpacity: 0,
        icon: _cardExists ? Icons.check : Icons.add,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.playlist_add),
            backgroundColor: Colors.grey.shade900,
            foregroundColor: Colors.teal.shade200,
            label: 'Add to Deck',
            onTap: () async {
              // Retrieve current decks from the provider
              final decks = ref.read(decksProvider);
              if (decks.isEmpty) {
                Fluttertoast.showToast(
                  msg: "No decks available. Please create a deck first.",
                  gravity: ToastGravity.CENTER,
                  textColor: Colors.teal.shade50,
                );
                return;
              }
              // Show a bottom sheet to select a deck
              final selectedDeckId = await showModalBottomSheet<String>(
                context: context,
                backgroundColor: Colors.grey.shade900,
                builder: (context) {
                  return ListView.builder(
                    itemCount: decks.length,
                    itemBuilder: (context, index) {
                      final deck = decks[index];
                      return ListTile(
                        title: Text(
                          deck.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.pop(context, deck.id);
                        },
                      );
                    },
                  );
                },
              );
              // If a deck was selected, add the card to that deck
              if (selectedDeckId != null) {
                ref
                    .read(decksProvider.notifier)
                    .addCardToDeck(selectedDeckId, widget.card!);
                Fluttertoast.showToast(
                  msg: "${widget.card!['name']} added to deck!",
                  gravity: ToastGravity.CENTER,
                  textColor: Colors.teal.shade50,
                );
              }
            },
          ),

          // Add to Watchlist Button
          SpeedDialChild(
            child: const Icon(Icons.visibility_outlined),
            backgroundColor: Colors.grey.shade900,
            foregroundColor: Colors.blue.shade300,
            label: 'Add to Watchlist',
            onTap: () {
              ref
                  .read(watchlistProvider.notifier)
                  .addToWatchlist(
                    WatchlistItem(
                      id: widget.card!['id'],
                      name: widget.card!['name'],
                      imageUrl: widget.card!['images']['small'],
                      price: double.tryParse(widget.card!['price'] ?? "0") ?? 0,
                      trendUp: false, // Provide a default or dynamic value
                    ),
                  );
              Fluttertoast.showToast(
                msg: "${widget.card!['name']} added to Watchlist!",
                gravity: ToastGravity.CENTER,
                textColor: Colors.teal.shade50,
              );
            },
          ),

          // Remove from Collection Button (if the card exists)
          if (_cardExists)
            SpeedDialChild(
              child: const Icon(Icons.delete_outline),
              backgroundColor: Colors.grey.shade900,
              foregroundColor: Colors.red.shade600,
              label: 'Remove from Collection',
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
                          "Are you sure you want to remove this card from your collection?",
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
                              await collectionService.removeCard(widget.card!);
                              Fluttertoast.showToast(
                                msg: "Card removed from collection!",
                                gravity: ToastGravity.CENTER,
                                textColor: Colors.teal.shade50,
                              );
                              _getCardExists();
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

          // Add to Collection Button (if not already in collection)
          if (!_cardExists)
            SpeedDialChild(
              child: const Icon(Icons.add),
              backgroundColor: Colors.grey.shade900,
              foregroundColor: Colors.teal.shade200,
              label: 'Add to Collection',
              onTap: () async {
                final collectionService = ref.read(collectionServiceProvider);
                await collectionService.addCard(widget.card!);
                // Add a notification for the card that was added
                ref
                    .read(notificationsProvider.notifier)
                    .addNotification(
                      NotificationItem(
                        title: "Card Added",
                        subtitle:
                            "${widget.card!['name']} was added to your collection",
                        time: DateTime.now(),
                      ),
                    );
                Fluttertoast.showToast(
                  msg: "Card added to collection!",
                  gravity: ToastGravity.CENTER,
                  textColor: Colors.teal.shade50,
                );
                _getCardExists();
              },
            ),
        ],
      ),
    );
  }
}
