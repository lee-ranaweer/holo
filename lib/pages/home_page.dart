import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../providers/watchlist_provider.dart';
import './details_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value!;
    final totalValue = ref.watch(portfolioValueProvider);
    final userProfile = ref.watch(userProfileProvider);
    final currentUser = ref.watch(authStateProvider).value!;
    final watchlist = ref.watch(
      watchlistProvider,
    ); // Watchlist updates in real-time

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Portfolio Balance Section
              Text(
                "Portfolio balance",
                style: TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.bold,
                  color: Colors.limeAccent.shade400
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "\$${totalValue.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                      letterSpacing: 1.2,
                    ),
                  ),
                  // Text(
                  //   "+220.4",
                  //   style: const TextStyle(
                  //     color: Colors.greenAccent,
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.w600,
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 20),

              // User Profile Section
              GestureDetector(
                onTap: () {
                  // go to user account page
                  context.go('/account');
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade900,
                  ),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey.shade800,
                            child: const Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userProfile.when(
                                data:
                                    (data) =>
                                        data?['username'] ?? currentUser.email!,
                                loading:
                                    () => currentUser.email ?? 'Loading...',
                                error: (_, __) => currentUser.email ?? 'Error',
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "New Portfolio User",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.show_chart,
                        color: Colors.white,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Watchlist Section with deletion mode support
              Expanded(child: WatchlistListWidget(watchlist: watchlist)),
            ],
          ),
        ),
      ),
    );
  }
}

class WatchlistListWidget extends StatefulWidget {
  final List<WatchlistItem> watchlist;
  const WatchlistListWidget({super.key, required this.watchlist});

  @override
  _WatchlistListWidgetState createState() => _WatchlistListWidgetState();
}

class _WatchlistListWidgetState extends State<WatchlistListWidget> {
  bool deletionMode = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header row with toggle for deletion mode and plus button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Watchlist",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    deletionMode ? Icons.close : Icons.remove_circle_outline,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      deletionMode = !deletionMode;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    context.go('/search');
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child:
              widget.watchlist.isEmpty
                  ? Center(
                    child: Text(
                      'No cards in watchlist',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  )
                  : ListView.builder(
                    itemCount: widget.watchlist.length,
                    itemBuilder: (context, index) {
                      final card = widget.watchlist[index];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutQuart,
                        margin: EdgeInsets.only(left: deletionMode ? 10 : 0),
                        child:
                            deletionMode
                                ? Row(
                                  children: [
                                    // Delete button for the item with elastic pop-in animation
                                    TweenAnimationBuilder<double>(
                                      tween: Tween<double>(begin: 0, end: 1),
                                      duration: const Duration(
                                        milliseconds: 600,
                                      ),
                                      curve: Curves.elasticOut,
                                      builder: (context, scale, child) {
                                        return Transform.scale(
                                          scale: scale,
                                          child: child,
                                        );
                                      },
                                      child: Consumer(
                                        builder: (context, ref, child) {
                                          return GestureDetector(
                                            onTap: () {
                                              ref
                                                  .read(
                                                    watchlistProvider.notifier,
                                                  )
                                                  .removeFromWatchlist(card.id);
                                            },
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.red,
                                              ),
                                              padding: const EdgeInsets.all(8),
                                              child: const Icon(
                                                Icons.remove,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: WatchlistTile(card: card)),
                                  ],
                                )
                                : GestureDetector(
                                  onTap: () {
                                    // Convert the WatchlistItem into a Map<String, dynamic>
                                    final cardMap = {
                                      'id': card.id,
                                      'name': card.name,
                                      'images': {
                                        'small': card.imageUrl,
                                        'large':
                                            card.imageUrl, // Using same image URL for large image.
                                      },
                                      'price': card.price.toString(),
                                      'set': {'name': 'Unknown'},
                                      'rarity': 'Unknown',
                                    };
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                DetailsPage(card: cardMap),
                                      ),
                                    );
                                  },
                                  child: WatchlistTile(card: card),
                                ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}

class WatchlistTile extends StatelessWidget {
  final WatchlistItem card;
  const WatchlistTile({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    bool isPricePositive = card.price > 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade900,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade800,
            radius: 18,
            backgroundImage: NetworkImage(card.imageUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              card.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            "\$${card.price.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            isPricePositive ? Icons.arrow_upward : Icons.arrow_downward,
            color: isPricePositive ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }
}
