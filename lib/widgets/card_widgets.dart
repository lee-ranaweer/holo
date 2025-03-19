import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import 'package:holo/pages/details_page.dart';

class CardGridItem extends ConsumerWidget {
  final Map<String, dynamic> card;
  final EdgeInsetsGeometry? margin;


  const CardGridItem({
    super.key,
    required this.card,
    this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      // decoration: BoxDecoration(
      //   color: Colors.grey.shade900,
      //   borderRadius: BorderRadius.circular(12),
      //   // boxShadow: [
      //   //   BoxShadow(
      //   //     color: Colors.black.withOpacity(0.3),
      //   //     blurRadius: 6,
      //   //     spreadRadius: 2,
      //   //   ),
      //   // ],
      // ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsPage(card: card)
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              
              children: [
                // Image Container with fixed aspect ratio
                SizedBox(
                  height: cardWidth * 1.4, // Height relative to card width
                  
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.network(
                      card['images']['small'],
                      
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Card Details with constrained height
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                    height: 45, // Fixed height for text content
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          card['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          card['set']['name'] ?? 'Unknown Set',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 9,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              card['rarity'] ?? 'Unknown Rarity',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 9,
                              ),
                            ),
                            Text(
                              '\$${card['price'] ?? 'N/A'}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }


  void _showCardDetails(BuildContext context, WidgetRef ref) {
    final isInCollection = ref.read(collectionProvider).maybeWhen(
          data: (cards) => cards.any((c) => c['id'] == card['id']),
          orElse: () => false,
        );

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    card['images']['large'],
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  card['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${card['price'] != "N/A" ? card['price'] : "N/A"}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Consumer(
                  builder: (context, ref, child) {
                    final collection = ref.watch(collectionProvider);
                    final isInCollection = collection.maybeWhen(
                      data: (cards) => cards.any((c) => c['id'] == card['id']),
                      orElse: () => false,
                    );

                    if (isInCollection) {
                      return Text(
                        'Already in Collection',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    }

                    return ElevatedButton(
                      onPressed: () async {
                        try {
                          final collectionService = 
                            ref.read(collectionServiceProvider);
                          await collectionService.addCard(card);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Card added to collection!')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                        }
                      },
                      child: const Text("Add to Collection"),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}