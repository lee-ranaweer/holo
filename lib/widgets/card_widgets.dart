import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

class CardListItem extends ConsumerWidget {
  final Map<String, dynamic> card;
  final Widget? trailing;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? margin;

  const CardListItem({
    super.key,
    required this.card,
    this.trailing,
    this.contentPadding,
    this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: Image.network(
          card['images']['small'],
          width: 50,
          height: 50,
        ),
        title: Text(
          card['name'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${card['set']['name'] ?? 'Unknown'} | ${card['rarity'] ?? 'Unknown'}',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
        trailing: trailing,
        onTap: () => _showCardDetails(context, ref),
      ),
    );
  }

  void _showCardDetails(BuildContext context, WidgetRef ref) {
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
                ElevatedButton(
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}