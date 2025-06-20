import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/decks_provider.dart';

class DeckDetailsPage extends ConsumerWidget {
  final String deckId;
  const DeckDetailsPage({Key? key, required this.deckId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decksAsync = ref.watch(decksProvider);

    return decksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (decks) {
        final deck = decks.firstWhere(
          (d) => d.id == deckId,
          orElse: () => DeckItem(
            id: '', 
            name: 'Unknown Deck',
            cards: [],
          ),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(deck.name),
            backgroundColor: Colors.grey.shade900,
          ),
          backgroundColor: Colors.black,
          body: deck.cards.isEmpty
              ? Center(
                  child: Text(
                    'No cards in ${deck.name}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: deck.cards.length,
                  itemBuilder: (context, index) {
                    final card = deck.cards[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          card['images']['small'],
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        card['name'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "Value: \$${card['price']}",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
