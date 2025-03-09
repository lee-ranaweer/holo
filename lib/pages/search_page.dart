import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> _cards = [];
  bool _isLoading = false;
  bool _search = false;
  String _errorMessage = '';

  Future<void> _searchCards(String query) async {
    if (query.isEmpty) return;
    _search = true;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final cards = await fetchPokemonCards(query);
      setState(() {
        _cards = cards;
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: 
                Row(
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
                          prefixIcon: const Icon(Icons.search, color: Colors.white),
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
                  ]
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
                _cards.isEmpty && !_search && !_isLoading ?
                  Center(
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
                _cards.isEmpty && _search && !_isLoading ?
                  Center(
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
                !_isLoading ?
                  ListView.builder(
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      final card = _cards[index];
                      return _buildCardItem(context, card);
                    },
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

  Widget _buildCardItem(BuildContext context, Map<String, dynamic> card) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      leading: Image.network(card['images']['small'], width: 50, height: 50),
      title: Text(
        card['name'],
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '${card['set']['name'] ?? 'Unknown'} | ${card['rarity'] ?? 'Unknown'}',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      ),
      onTap: () => _showCardDetails(context, card),
    );
  }

  void _showCardDetails(BuildContext context, Map<String, dynamic> card) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
              maxWidth: MediaQuery.of(context).size.width * 0.95,
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Card Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      card['images']['large'],
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title & Price Section (FIXED)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Card Name & Set - Wrapped in Expanded to prevent overflow
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow:
                                  TextOverflow
                                      .ellipsis, // Prevents long names from breaking layout
                            ),
                            const SizedBox(height: 2),
                            Text(
                              card['set']['name'],
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Price Section - Wrapped in Flexible to avoid breaking layout
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(
                              Icons.arrow_upward,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            FittedBox(
                              fit:
                                  BoxFit
                                      .scaleDown, // Ensures the text does not overflow
                              child: Text(
                                card['price'] != "N/A"
                                    ? "\$${card['price']}"
                                    : "N/A",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // "Add to Collection" Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Card added to collection'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Add to Collection'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
