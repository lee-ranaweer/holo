import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import 'package:holo/pages/details_page.dart';

class CardListItem extends ConsumerWidget {
  final Map<String, dynamic> card;

  const CardListItem({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      leading: Image.network(card['images']['small'], width: 50, height: 50),
      title: Text(
        card['name'],
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '${card['set']['name'] ?? 'Unknown'} • ${card['rarity'] ?? 'Unknown'}',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      ),
      trailing: Text(
        card['price'] != "N/A" ? "\$${double.parse(card['price']).toStringAsFixed(2)}" : "N/A",
        style: const TextStyle(
          color: Colors.green,
          fontSize: 16,
          fontWeight: FontWeight.bold
        ),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsPage(card: card),
        ),
      ),
    );
  }

    Widget _buildCollectionCard(BuildContext context, Map<String, dynamic> card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        leading: Image.network(card['images']['small'], width: 60, height: 60),
        title: Text(
          card['name'],
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          card['set']['name'],
          style: TextStyle(color: Colors.grey.shade500),
        ),
        trailing: Text(
          '\$${card['price']}',
          style: const TextStyle(
            color: Colors.green,
            fontSize: 16,
            fontWeight: FontWeight.bold
          ),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsPage(card: card)
          ),
        ),
      ),
    );
  }
}

