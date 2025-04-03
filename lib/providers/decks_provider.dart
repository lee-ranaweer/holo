import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

final deckServiceProvider = Provider<DeckService>((ref) => DeckService());

class DeckService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _userDecksRef {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');
    return _firestore.collection('users').doc(user.uid).collection('decks');
  }

  Future<void> createDeck(String name) async {
  await _userDecksRef.doc().set({
    'id': const Uuid().v4(),
    'name': name,
    'createdAt': FieldValue.serverTimestamp(),
    'lastUpdated': FieldValue.serverTimestamp(),
  });
}


  Future<void> addCardToDeck({
  required String deckId,
  required Map<String, dynamic> card,
}) async {
  final deckRef = _userDecksRef.doc(deckId);
  await FirebaseFirestore.instance.runTransaction((transaction) async {
    transaction.set(
      deckRef.collection('cards').doc(card['id']),
      card,
    );
    transaction.update(deckRef, {
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  });
}

  Stream<List<DeckItem>> watchDecks() {
    return _userDecksRef
      .orderBy('lastUpdated', descending: true)
      .snapshots()
      .asyncMap((snapshot) async {
      final decks = await Future.wait(
        snapshot.docs.map((doc) async {
          final cardsSnapshot = await doc.reference.collection('cards').get();
          return DeckItem(
            id: doc.id,
            name: doc['name'],
            cards: cardsSnapshot.docs.map((cardDoc) => cardDoc.data()).toList(),
          );
        }),
      );
      return decks;
    });
  }

  Future<void> deleteDeck(String deckId) async {
    await _userDecksRef.doc(deckId).delete();
  }

}

class DeckItem {
  final String id;
  final String name;
  final List<Map<String, dynamic>> cards;

  DeckItem({
    required this.id,
    required this.name,
    required this.cards,
  });
}

class DecksNotifier extends StateNotifier<AsyncValue<List<DeckItem>>> {
  final Ref ref;
  
  DecksNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  String _curDeck = "";
  String get curDeck => _curDeck;
  set curDeck(String deck) => _curDeck = deck;

  Future<void> _init() async {
    ref.read(deckServiceProvider).watchDecks().listen((decks) {
      state = AsyncValue.data(decks);
    }).onError((error) {
      state = AsyncValue.error(error, StackTrace.current);
    });
  }

  Future<void> addDeck(String deckName) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(deckServiceProvider).createDeck(deckName);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addCardToDeck(String deckId, Map<String, dynamic> card) async {
    try {
      await ref.read(deckServiceProvider).addCardToDeck(
        deckId: deckId,
        card: card,
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteDeck(String deckId) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(deckServiceProvider).deleteDeck(deckId);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  

}

final decksProvider = StateNotifierProvider<DecksNotifier, AsyncValue<List<DeckItem>>>(
  (ref) => DecksNotifier(ref),
);
