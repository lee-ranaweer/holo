import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import 'package:holo/pages/details_page.dart';

class CollectionFilter extends ConsumerWidget {
  const CollectionFilter({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const rarityOptions = [
      'Unknown',
      'Common',
      'Uncommon',
      'Rare',
      'Rare Holo',
      'Promo',
      'Ultra Rare',
      'Hyper Rare',
      'Double Rare',
      'Secret Rare',
    ];

    final currentSelection = ref.read(selectedRaritiesProvider);
    var tempSelection = Set<String>.from(currentSelection);

    return StatefulBuilder(
      builder: (context, setState) {
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Filter by Rarity",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ...rarityOptions.map((rarity) {
                  return CheckboxListTile(
                    title: Text(
                      rarity,
                      style: TextStyle(color: Colors.white),
                    ),
                    value: tempSelection.contains(rarity),
                    activeColor: Colors.green,
                    checkColor: Colors.white,
onChanged: (bool? value) {
  setState(() {
    if (value == true) {
      tempSelection.add(rarity);
    } else {
      tempSelection.remove(rarity);
    }
  });
},
                  );
                }),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        tempSelection.clear();
                        ref.read(selectedRaritiesProvider.notifier).state = tempSelection;
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Clear',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(selectedRaritiesProvider.notifier).state = tempSelection;
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

