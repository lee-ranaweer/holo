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
import 'package:url_launcher/url_launcher.dart';
import '../providers/notifications_provider.dart'; // New import
import '../providers/decks_provider.dart'; // Import decksProvider

class DetailsPage extends ConsumerStatefulWidget {
  const DetailsPage({super.key, required this.card});

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
    // print(widget.card!["tcgplayer"]);

    final response = await http.Client().get(Uri.parse(widget.card!['tcgplayer']));
    // print(response.statusCode);


    dom.Document htmldom = dom.Document.html(response.body);
    final titles = htmldom.querySelectorAll('div > h1')
    .map((element) => element.innerHtml.trim())
    .toList();

    // print(titles.length);
    // for (final title in titles) {
    //   print(title);
    // }

    if (response.statusCode == 200) {
      // get html doc from response
      var doc = parser.parse(response.body);
      // print(doc.body?.children[0].nextElementSibling?.localName);
      try {
        // scrape
        var responseString1 = doc.getElementById("title");
        
        // print(responseString1?.text);
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
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 100
          ),
          children: [
            Column(
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

                // card name
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
                Text(
                  '${widget.card!['number']}/${widget.card!['set']['total']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),

                // Card Info
                Row(
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
                              widget.card!['price'] != "N/A" ? "\$${double.parse(widget.card!['price']).toStringAsFixed(2)}" : "N/A",
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
                const SizedBox(height: 24),
                // Historical Price Info
                Text(
                  'Historical Value',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                PriceChart(),
                // tcgplayer url
                InkWell(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'View in TCGplayer ',
                          style: TextStyle(
                            color: Colors.teal.shade50,
                            fontSize: 12,
                          ),
                        ),
                        WidgetSpan(
                          child: Icon(Icons.open_in_new, size: 15, color: Colors.teal.shade50)
                        )
                      ]
                    ),
                  ),
                  onTap: () => launchUrl(Uri.parse(widget.card!['tcgplayer'])),
                ),
                const SizedBox(height: 12),
                // Additional Card Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // artist info
                    Flexible(
                      flex: 1,
                      child: Column(
                        children: [
                          Text(
                            'Artist',
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
                              widget.card!['artist'] ?? 'Unknown',
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
                    // release date info
                    Flexible(
                      flex: 1,
                      child: Column(
                        children: [
                          Text(
                            'Release Date',
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
                              widget.card!['set']['releasedate'] ?? 'Unknown',
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
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      // Floating Action Button: SpeedDial with options
      floatingActionButton: SpeedDial(
        label:
            _cardExists ? const Text('In Collection') : const Text('Options'),
        backgroundColor: Colors.grey.shade900,
        foregroundColor: 
            _cardExists ? Colors.teal.shade50 : Colors.teal.shade200,
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
          // Add to Watchlist Button
          SpeedDialChild(
            child: const Icon(Icons.visibility_outlined),
            backgroundColor: Colors.grey.shade900,
            foregroundColor: Colors.blue.shade300,
            label: 'Add to watchlist',
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

          // Add to Collection Button (if not already in collection)
          if (!_cardExists)
            SpeedDialChild(
              child: const Icon(Icons.add),
              backgroundColor: Colors.grey.shade900,
              foregroundColor: Colors.teal.shade200,
              label: 'Add to collection',
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

          // Add to Deck Button (if in collection)
          if (_cardExists)
            SpeedDialChild(
              child: const Icon(Icons.playlist_add),
              backgroundColor: Colors.grey.shade900,
              foregroundColor: Colors.teal.shade200,
              label: 'Add to a deck',
              onTap: () async {
                // Retrieve current decks from the provider
                final decks = ref.read(decksProvider);
                if (decks.isEmpty) {
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

          // Remove from Collection Button (if in collection)
          if (_cardExists)
            SpeedDialChild(
              child: const Icon(Icons.delete_outline),
              backgroundColor: Colors.grey.shade900,
              foregroundColor: Colors.red.shade600,
              label: 'Remove from collection',
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
                              // update card detail state
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
        ],
      ),
    );
  }
}
