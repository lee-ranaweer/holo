import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:holo/widgets/price_chart.dart';
import '../services/auth_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../providers/watchlist_provider.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
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
    _testScrape();
  }

  _getCardExists() async {
    final collectionService = ref.read(collectionServiceProvider);
    bool cardExists = await collectionService.checkCard(widget.card!['id']);
    setState(() {
      _cardExists = cardExists;
    });
  }

  _testScrape() async {
    // print(widget.card!["priceupdate"]);
    // print(widget.card!["prices"]);
    // print(widget.card!['cardmarket']);
    print(widget.card!["tcgplayer"]);

    final response = await http.Client().get(Uri.parse(widget.card!['tcgplayer']));
    print(response.statusCode);


    dom.Document htmldom = dom.Document.html(response.body);
    final titles = htmldom.querySelectorAll('div > h1')
    .map((element) => element.innerHtml.trim())
    .toList();

    print(titles.length);
    for (final title in titles) {
      print(title);
    }

    if (response.statusCode == 200) {
      // get html doc from response
      var doc = parser.parse(response.body);
      print(doc.body?.children[0].nextElementSibling?.localName);
      try {
        // scrape
        var responseString1 = doc.getElementById("title");
        
        print(responseString1?.text);
      }
      catch (e) {
        print('error');
      }
    } else {
      print('no response');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Card Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        toolbarHeight: 50,
      ),
      body: SafeArea(
        child: ListView(
          // shrinkWrap: true,
          // padding: EdgeInsets.all(15.0),
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            // Card Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
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
                  // Card Info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.card!['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        // card number in set
                        Container(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            ' (${widget.card!['number']}/${widget.card!['set']['total']})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Set Info
                        Flexible(
                          flex: 3,
                          child: Column(
                            children: [
                              Text(
                                'Set',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  widget.card!['set']['name'] ?? 'Unknown',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Rarity Info
                        Flexible(
                          flex: 2,
                          child: Column(
                            children: [
                              Text(
                                'Rarity',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  widget.card!['rarity'] ?? 'Unknown',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  widget.card!['price'] != "N/A" ? "\$${widget.card!['price']}" : "N/A",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
            // Price info
            PriceChart(),
          ],
        ),
      ),
      // Floating Action Button: SpeedDial with options
      floatingActionButton: SpeedDial(
        label:
            _cardExists ? const Text('In Collection (1)') : const Text('Options'),
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.teal.shade50,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.grey.shade800,
            width: 1,
            style: BorderStyle.solid
          ),
          borderRadius: BorderRadius.circular(28.0),
        ),
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
            // TODO: check if already in watchlist, and display "In Watchlist"
            // Button should remove from watchlist
          ),

          // Add multiple of the same card
          if (_cardExists)
            SpeedDialChild(
              child: const Icon(Icons.add_circle_outline),
              backgroundColor: Colors.grey.shade900,
              foregroundColor: Colors.green.shade300,
              label: 'Edit Quantity',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
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
                              "Edit Quantity",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              overflow:
                                  TextOverflow
                                      .ellipsis, // Prevents long names from breaking layout
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton.filled(
                                  onPressed: () {

                                  },
                                  icon: const Icon(Icons.remove),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.grey.shade800,
                                    foregroundColor: Colors.white
                                  ),
                                ),
                                const SizedBox(
                                  width: 20.0,
                                  child: TextField(),
                                ),
                                IconButton.filled(
                                  onPressed: () {

                                  },
                                  icon: const Icon(Icons.add),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.grey.shade800,
                                    foregroundColor: Colors.white
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }
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
