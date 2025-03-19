import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Access point for authentication methods
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Keeps track of user authentication state
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Watches user Firestore data for updates
final userProfileProvider = StreamProvider.autoDispose((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snap) => snap.data());
});

final collectionServiceProvider = Provider<CollectionService>((ref) {
  return CollectionService();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final selectedRaritiesProvider = StateProvider<Set<String>>((ref) => Set());

final filteredCollectionProvider = Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final collectionAsync = ref.watch(collectionProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final selectedRarities = ref.watch(selectedRaritiesProvider);

  return collectionAsync.when(
    data: (cards) {
      final filtered = cards.where((card) {
        final nameMatch = query.isEmpty || 
            card['name'].toLowerCase().contains(query);
        
        final cardRarity = card['rarity']?.toLowerCase() ?? 'unknown';
        final rarityMatch = selectedRarities.isEmpty ||
            selectedRarities.any((rarity) => 
                cardRarity.contains(rarity.toLowerCase()));

        return nameMatch && rarityMatch;
      }).toList();
      return AsyncData(filtered);
    },
    loading: () => const AsyncLoading(),
    error: (error, stackTrace) => AsyncError(error, stackTrace),
  );
});

class CollectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add card to user's collection
  Future<void> addCard(Map<String, dynamic> card) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');
    
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cards')
        .doc(card['id'])
        .set(card);
  }

  // Check existing card from collection
  Future<bool> checkCard(String cardId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');

    try {
      var ref = _firestore.collection('users')
        .doc(user.uid)
        .collection('cards');
      var card = await ref.doc(cardId).get();
      return card.exists;
    } catch (e) {
      throw e;
    }
  }

  // Remove card from user's collection
  Future<void> removeCard(Map<String, dynamic> card) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');
    
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cards')
        .doc(card['id'])
        .delete().then(
          (doc) => print('Card deleted.'),
          onError: (e) => print("Unable to delete card"),
        );
  }

  // Stream of user's collected cards
  Stream<QuerySnapshot> get userCards {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');
    
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cards')
        .snapshots();
  }
}

final collectionProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('cards')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
});

  final portfolioValueProvider = Provider<double>((ref) {
    final collection = ref.watch(collectionProvider);
    return collection.maybeWhen(
      data: (cards) => cards.fold(0.0, (total, card) {
        final price = double.tryParse(card['price'] ?? '0') ?? 0.0;
        return total + price;
      }),
      orElse: () => 0.0,
    );
  });

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; 

  // Signup
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Store username in Firebase
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'username': username,
    });

    return userCredential;
  }

  // Login
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Signout
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
}
