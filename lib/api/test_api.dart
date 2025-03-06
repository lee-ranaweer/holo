import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

// Function to fetch cards by name
Future<List<Map<String, dynamic>>> fetchPokemonCards(String name) async {
  final apiKey = 'edb66ad4-7257-4c7a-ae99-064750a2909e'; // Your API Key
  final url = Uri.parse('https://api.pokemontcg.io/v2/cards?q=name:$name');

  final response = await http.get(
    url,
    headers: {
      'X-Api-Key': apiKey, // Include API Key in headers
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final List<dynamic> cards = jsonResponse['data']; // Extract card data
    return cards
        .map(
          (card) => {
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
            "tcgplayer": card['tcgplayer']?['url'],
          },
        )
        .toList();
  } else {
    throw Exception("Failed to load Pokemon cards: ${response.body}");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Map<String, dynamic>> _cards = [];
  bool _isLoading = false;
  String _errorMessage = '';

  void _searchCard(String name) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final cards = await fetchPokemonCards(name);
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Pokemon TCG Search')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onSubmitted: _searchCard,
                decoration: const InputDecoration(
                  labelText: 'Enter Pokemon Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            if (_isLoading) const CircularProgressIndicator(),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  return ListTile(
                    leading: Image.network(card['images']['small']),
                    title: Text(card['name']),
                    subtitle: Text(
                      'HP: ${card['hp'] ?? 'N/A'} | Rarity: ${card['rarity'] ?? 'Unknown'}',
                    ),
                    onTap: () => _showCardDetails(context, card),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCardDetails(BuildContext context, Map<String, dynamic> card) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(card['name']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(card['images']['large']),
              const SizedBox(height: 10),
              Text('HP: ${card['hp'] ?? 'N/A'}'),
              Text('Rarity: ${card['rarity'] ?? 'Unknown'}'),
              Text('Set: ${card['set']['name']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
