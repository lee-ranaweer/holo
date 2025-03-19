import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/card_widgets.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> _cards = [];
  bool _isLoading = false;
  bool _search = false;
  var _setFilter, _rarFilter;
  String _errorMessage = '';

  Future<void> _searchCards(String query) async {
    if (query.isEmpty) return;
    _search = true;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final fetchedCards = await fetchPokemonCards(query);

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
        }
        else {
          _cards = fetchedCards;
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
        return {
          "id": card['id'],
          "name": card['name'],
          "hp": card['hp'],
          "rarity": card['rarity'],
          "types": card['types'],
          "set": {"id": card['set']['id'], "name": card['set']['name']},
          "images": {
            "small": card['images']['small'],
            "large": card['images']['large'],
          },
          "price": price != null ? price.toString() : "N/A",
          "tcgplayer": card['tcgplayer']?['url'],
        };
      }).toList();
    } else {
      throw Exception("Failed to load Pokémon cards: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
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
                      onSubmitted: _searchCards,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade900,
                        hintText: 'Search Pokémon Cards...',
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
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: GestureDetector(
                      onTap: () => _showFilter(context),
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
                      :
                      // No Cards
                      _cards.isEmpty && _search && !_isLoading
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
                      ? GridView.builder(
                          padding: const EdgeInsets.all(5),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.55, // Adjusted aspect ratio
                          ),
                          itemCount: _cards.length,
                          itemBuilder: (context, index) => CardListItem(card: _cards[index]),
                        )
                      :
                      // Loading Indicator
                      const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
            ),
          ],
        ),
      ),
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
