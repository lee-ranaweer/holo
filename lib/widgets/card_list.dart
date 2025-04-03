import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holo/pages/collections_page.dart';
import '../services/auth_service.dart';
import 'package:holo/pages/details_page.dart';

class CardListItem extends ConsumerStatefulWidget {
  const CardListItem({super.key, required this.index, required this.card, required this.callbackFunction, required this.selectMode, required this.selectedCards, required this.extraCallback});

  final int index;
  final Map<String, dynamic> card;
  final Function callbackFunction;
  final bool selectMode;
  final List<Map<String, dynamic>> selectedCards;
  final Function extraCallback;

  @override
  CardListItemState createState() => CardListItemState();
}

class CardListItemState extends ConsumerState<CardListItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      leading: Image.network(widget.card['images']['small'], width: 50, height: 50),
      title: Text(
        widget.card['name'],
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '${widget.card['set']['name'] ?? 'Unknown'} • ${widget.card['rarity'] ?? 'Unknown'}',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      ),
      trailing: Text(
        widget.card['price'] != "N/A" ? "\$${double.parse(widget.card['price']).toStringAsFixed(2)}" : "N/A",
        style: const TextStyle(
          color: Colors.green,
          fontSize: 16,
          fontWeight: FontWeight.bold
        ),
      ),
      onTap: () {
        if (!widget.selectMode) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsPage(card: widget.card),
            ),
          );
        } else {
          setState(() {
            // add card to selection
            if (!widget.selectedCards.contains(widget.card)) {
              widget.selectedCards.add(widget.card);
            } else {
              widget.selectedCards.remove(widget.card);
            }
          });
          widget.extraCallback();
          print(widget.selectedCards.length);
        }
      },
      onLongPress: () {
        if (!widget.selectMode) {
          // activate select mode
          widget.callbackFunction();
          // add card to selection
          widget.selectedCards.add(widget.card);
          widget.extraCallback();
        }
      },
      selected: widget.selectedCards.contains(widget.card),
      selectedTileColor: Colors.grey.shade900,
    );
  }
}

