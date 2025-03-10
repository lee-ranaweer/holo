import 'package:flutter_riverpod/flutter_riverpod.dart';

// Model class for watchlist items
class WatchlistItem {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final bool trendUp;

  WatchlistItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.trendUp, //not sure how to use this rn
  });
}

// StateNotifier to manage the watchlist
class WatchlistNotifier extends StateNotifier<List<WatchlistItem>> {
  WatchlistNotifier() : super([]);

  void addToWatchlist(WatchlistItem item) {
    if (!state.any((card) => card.id == item.id)) {
      state = [...state, item]; // Add the new card to the list
    }
  }

  void removeFromWatchlist(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

// Riverpod provider for watchlist management
final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, List<WatchlistItem>>(
      (ref) => WatchlistNotifier(),
    );
