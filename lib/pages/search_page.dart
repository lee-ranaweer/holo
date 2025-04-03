import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:holo/providers/notifications_provider.dart';
import 'package:holo/services/auth_service.dart';
import 'package:holo/widgets/card_list.dart';
import 'package:http/http.dart' as http;
import '../widgets/card_grid.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends ConsumerState<SearchPage> {
  List<Map<String, dynamic>> _cards = [];
  bool _isLoading = false;
  bool _search = false;
  var _setFilter, _rarFilter;
  String _errorMessage = '';
  bool _gridMode = false;
  bool _selectMode = false;
  List<Map<String, dynamic>> _selectedCards = [];
  int _cardqty = 0;

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
    setState(() {});
  }

  Future<void> _searchCards(String query) async {
    if (query.isEmpty) return;
    _search = true;
    _cardqty = 0;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final fetchedCards = await fetchPokemonCards(query);
      print(fetchedCards);

      // apply filter
      List<Map<String, dynamic>> filteredCards = [];
      for (var card in fetchedCards) {
        bool addCard = true;
        if (_setFilter != null && _setFilter != "None" &&
          (card['set']['name'] == null || !card['set']['name'].toString().contains(_setFilter.toString())))
        {
          addCard = false;
        }
        if (_rarFilter != null && _rarFilter != "None" && 
          (card['rarity'] == null || card['rarity'] != _rarFilter))
        {
          addCard = false;
        }
        if (addCard) {
          filteredCards.add(card);
        }
      }

      setState(() {
        if ((_setFilter != null && _setFilter != "None") ||
          (_rarFilter != null && _rarFilter != "None")) {
          _cards = filteredCards;
          _cardqty = filteredCards.length;
        }
        else {
          _cards = fetchedCards;
          _cardqty = fetchedCards.length;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchPokemonCards(String name) async {
    final apiKey = 'edb66ad4-7257-4c7a-ae99-064750a2909e'; // Your API Key
    name = name.trim().replaceAll(' ', '&');
    name = name.replaceAll('’', '%27');
    final url = Uri.parse('https://api.pokemontcg.io/v2/cards?q=name:$name*');
    print(url);

    final response = await http.get(url, headers: {'X-Api-Key': apiKey});

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> cards = jsonResponse['data'];
      return cards.map((card) {
        // Attempt to get the market price from the tcgplayer object.
        final price = card['tcgplayer']?['prices']?['holofoil']?['market'];
        // price update
        final priceUpdate = card['tcgplayer']?['updatedAt'];
        return {
          "id": card['id'],
          "name": card['name'],
          "number": card['number'],
          "artist": card['artist'],
          "hp": card['hp'],
          "rarity": card['rarity'],
          "types": card['types'],
          "set": {"id": card['set']['id'], "name": card['set']['name'], 
            "total": card['set']['total'], "releasedate": card['set']['releaseDate']},
          "images": {
            "small": card['images']['small'],
            "large": card['images']['large'],
          },
          "price": price != null ? price.toString() : "N/A",
          "priceupdate": priceUpdate != null ? priceUpdate.toString() : "N/A",
          "prices": card['tcgplayer']?['prices'],
          "tcgplayer": card['tcgplayer']?['url'],
          "cardmarket": card['cardmarket']?['prices']?['trendPrice']
        };
      }).toList();
    } else {
      throw Exception("Failed to load Pokémon cards: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 0, //no padding!
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
                  if (_selectMode)
                    Row(
                      children: [
                        // multi-select
                        Text(
                          "${_selectedCards.length} selected",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        // cancel
                        IconButton(
                          onPressed: () {
                            toggleSelectMode();
                          },
                          icon: const Icon(Icons.close, size: 20),
                        ),
                      ],
                    ),

                   // Search, filter, and view mode
                   Row(
                    children: [
                      // Search Bar
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            onSubmitted: _searchCards,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade900,
                              hintText: 'Search Pokémon cards...',
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

                      // Filter
                      IconButton(
                        onPressed: () {
                          _showFilter(context);
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
                        )
                    ],
                  ),
                  const SizedBox(height: 12),

                  // qty
                  if (_search)
                    Text(
                      'Showing: $_cardqty result(s)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  
                  // Divider for separation
                  if (_search)
                    Divider(color: Colors.grey.shade800, thickness: 1),
                ],
              ),
            ),

            // Error Message
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // Search Results
            Expanded(
              child:
              // Search Cards
              _cards.isEmpty && !_search && !_isLoading
              ? Center(
                child: Text(
                  'Search for a Pokémon card',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              )
              // No Cards
              : _cards.isEmpty && _search && !_isLoading
              ? Center(
                  child: Text(
                    'No cards found',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                )
              :
              // Card List
              !_isLoading
              ? _gridMode 
                ? GridView.builder(
                    padding: const EdgeInsets.all(5),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.55, // Adjusted aspect ratio
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (context, index) { 
                      return CardGridItem(key: ValueKey(index), index: index, card: _cards[index],
                        callbackFunction: toggleSelectMode, selectMode: _selectMode, selectedCards: _selectedCards,
                          extraCallback: refresh);
                    }
                  )
                : ListView.builder(
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      return CardListItem(index: index, card: _cards[index], 
                        callbackFunction: toggleSelectMode, selectMode: _selectMode, selectedCards: _selectedCards,
                          extraCallback: refresh);
                    }
                  )
              // Loading Indicator
              : Align(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
            ),
          ],
        ),
      ),
      floatingActionButton:
      !_selectMode || _selectedCards.isEmpty
      ?
      null
      // Multi-select options
      : SpeedDial(
          label: const Text('Options'),
          backgroundColor: Colors.grey.shade900,
          foregroundColor: Colors.teal.shade200,
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
            SpeedDialChild(
              child: const Icon(Icons.add),
              backgroundColor: Colors.grey.shade900,
              foregroundColor: Colors.teal.shade200,
              label: 'Add card(s) to collection',
              onTap: () async {
                final collectionService = ref.read(collectionServiceProvider);
                for (final card in _selectedCards) {
                  await collectionService.addCard(card);
                  // Add a notification for the card that was added
                  ref
                  .read(notificationsProvider.notifier)
                  .addNotification(
                    NotificationItem(
                      title: "Card Added",
                      subtitle:
                          "$card was added to your collection",
                      time: DateTime.now(),
                    ),
                  );
                }
                Fluttertoast.showToast(
                  msg: "${_selectedCards.length} cards added to collection!",
                  gravity: ToastGravity.CENTER,
                  textColor: Colors.teal.shade50,
                );
                toggleSelectMode();
              },
            ),
          ],
        )
    );
  }

  void _showFilter(BuildContext context) {
    const List<String> setlist = <String>['None', 'Base', 'Neo', 'Ruby & Sapphire', 'Diamond & Pearl'];
    const List<String> rarlist = <String>['None', 'Common', 'Uncommon', 'Rare', 'Rare Holo'];
    var setFil = _setFilter ?? setlist.first;
    var rarFil = _rarFilter ?? rarlist.first;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.32,
              maxWidth: MediaQuery.of(context).size.width * 0.5,
            ),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Filter By",
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
                Text(
                  "Set",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
                StatefulBuilder(
                  builder: (context, state) {
                    return DropdownButton<String>(
                      value: setFil,
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 16,
                      style: const TextStyle(color: Colors.white),
                      dropdownColor: Colors.grey.shade900,
                      isExpanded: true,
                      onChanged: (String? value) {
                        state(() {
                          setFil = value!;
                        });
                      },
                      items: 
                        setlist.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value));
                        }).toList(),
                    );
                  }
                ),
                Text(
                  "Rarity",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
                StatefulBuilder(
                  builder: (context, state) {
                    return DropdownButton<String>(
                      value: rarFil,
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 16,
                      style: const TextStyle(color: Colors.white),
                      dropdownColor: Colors.grey.shade900,
                      isExpanded: true,
                      onChanged: (String? value) {
                        state(() {
                          rarFil = value!;
                        });
                      },
                      items: 
                        rarlist.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value));
                        }).toList(),
                    );
                  }
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _setFilter = setFil;
                    _rarFilter = rarFil;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 6,
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

