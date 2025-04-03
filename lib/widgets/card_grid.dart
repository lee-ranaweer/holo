import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import 'package:holo/pages/details_page.dart';

class CardGridItem extends ConsumerStatefulWidget {
  const CardGridItem({super.key, required this.index, required this.card, this.margin, required this.callbackFunction, required this.selectMode, required this.selectedCards, required this.extraCallback});

  final int index;
  final Map<String, dynamic> card;
  final EdgeInsetsGeometry? margin;
  final Function callbackFunction;
  final bool selectMode;
  final List<Map<String, dynamic>> selectedCards;
  final Function extraCallback;

  @override
  CardGridItemState createState() => CardGridItemState();
}

class CardGridItemState extends ConsumerState<CardGridItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: !widget.selectedCards.contains(widget.card) ? Colors.black : Colors.grey.shade900,
      child: InkWell(
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
                if (widget.selectedCards.isEmpty) {
                  // deactivate select mode
                  widget.callbackFunction();
                }
              }
            });
            widget.extraCallback();
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
        child: Container(
          margin: widget.margin ?? const EdgeInsets.all(8),
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
                        widget.card['images']['small'],
                        
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
                            widget.card['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.card['set']['name'] ?? 'Unknown Set',
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
                                widget.card['rarity'] ?? 'Unknown Rarity',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 9,
                                ),
                              ),
                              Text(
                                widget.card['price'] != "N/A" ? "\$${double.parse(widget.card['price']).toStringAsFixed(2)}" : "N/A",
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
      ),
    );
  }
}

