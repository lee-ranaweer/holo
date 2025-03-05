import 'package:flutter/material.dart';
import 'package:pokemon_tcg/pokemon_tcg.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Heres our api key
  final api = PokemonTcgApi(apiKey: 'edb66ad4-7257-4c7a-ae99-064750a2909e');
  // Get cards from base et
  final cards = await api.getCardsForSet('base1');

  final jsonResponse =
      cards.map((card) {
        return {
          "id": card.id,
          "name": card.name,
          "hp": card.hp,
          "rarity": card.rarity,
          "types": card.types,
          "set": {"id": card.set.id, "name": card.set.name},
          "images": {"small": card.images.small, "large": card.images.large},
          "cardmarket": card.tcgPlayer
        };
      }).toList();

  print("Full JSON response: $jsonResponse");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Holo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Holo Pokemon TCG fetch test')),
        body: const Center(child: Text('API response in console')),
      ),
    );
  }
}
