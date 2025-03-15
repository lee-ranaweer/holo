import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class DetailsPage extends ConsumerWidget {
  Map<String, dynamic>? card;
  DetailsPage({super.key, this.card}); 

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Stack(
                children: [
                  // Back Button
                  Container(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => context.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 20),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                  // Title
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Card Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Card Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      card!['images']['large'],
                      fit: BoxFit.contain,
                      height: 400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title & Price
                  Text(
                    card!['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // set info
                        Flexible(
                          flex: 1,
                          child: Column(
                            children: [
                              Text(
                                'Set',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                card!['set']['name'] ?? 'Unknown',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // rarity info
                        Flexible(
                          flex: 1,
                          child: Column(
                            children: [
                              Text(
                                'Rarity',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                card!['rarity'] ?? 'Unknown',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // price info
                        Flexible(
                          flex: 1,
                          child: Column(
                            children: [
                              Text(
                                'Value',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "\$${card!['price'] != "N/A" ? card!['price'] : "N/A"}",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          )
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Add to collection
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          try {
            final collectionService = ref.read(collectionServiceProvider);
            await collectionService.addCard(card!);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Card added to collection!'),
                action: SnackBarAction(
                  label: 'View card',
                  onPressed: () {
                    context.go('/collections');
                  },
                ),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${e.toString()}')),
            );
          }
        },
        label: const Text('Add To Collection'),
        backgroundColor: Colors.grey.shade900,
        // foregroundColor: Colors.grey.shade900,
      ),
    );
  }
}