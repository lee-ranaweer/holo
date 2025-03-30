import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// Updated Deck model to hold a list of cards (using Map<String, dynamic>)
class DeckItem {
  final String id;
  final String name;
  final List<Map<String, dynamic>> cards;

  DeckItem({
    required this.id,
    required this.name,
    List<Map<String, dynamic>>? cards,
  }) : cards = cards ?? [];
}

// A simple StateNotifier to manage decks.
class DecksNotifier extends StateNotifier<List<DeckItem>> {
  DecksNotifier() : super([]);

  final _uuid = const Uuid();
  
  String _curDeck = "";
  String get curDeck => _curDeck;

  set curDeck(String deck) {
    _curDeck = deck;
  } 


  // Create a new deck
  void addDeck(String deckName) {
    final newDeck = DeckItem(id: _uuid.v4(), name: deckName);
    state = [...state, newDeck];
  }

  // Add a card to an existing deck (if not already added, if you want to prevent duplicates you could check)
  void addCardToDeck(String deckId, Map<String, dynamic> card) {
    state =
        state.map((deck) {
          if (deck.id == deckId) {
            return DeckItem(
              id: deck.id,
              name: deck.name,
              cards: [...deck.cards, card],
            );
          }
          return deck;
        }).toList();
  }
}

// Provider for decks
final decksProvider = StateNotifierProvider<DecksNotifier, List<DeckItem>>(
  (ref) => DecksNotifier(),
);
