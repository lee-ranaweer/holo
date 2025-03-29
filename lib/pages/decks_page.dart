import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/decks_provider.dart';

class DecksPage extends ConsumerWidget {
  const DecksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decks = ref.watch(decksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Decks',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Decks Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  itemCount: decks.length + 1,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Add new deck tile
                      return GestureDetector(
                        onTap: () async {
                          final newDeckName = await showDialog<String>(
                            context: context,
                            builder: (context) {
                              final TextEditingController _deckNameController =
                                  TextEditingController();

                              return AlertDialog(
                                backgroundColor: Colors.grey.shade900,
                                titleTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                                contentTextStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                                title: const Text("Create New Deck"),
                                content: TextField(
                                  controller: _deckNameController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: "Enter deck name",
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.teal,
                                      ),
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final text =
                                          _deckNameController.text.trim();
                                      if (text.isNotEmpty) {
                                        Navigator.pop(context, text);
                                      }
                                    },
                                    child: const Text(
                                      'Create',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );

                          if (newDeckName != null && newDeckName.isNotEmpty) {
                            ref
                                .read(decksProvider.notifier)
                                .addDeck(newDeckName);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: Colors.grey.shade800,
                              width: 1,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Existing deck
                      final deck = decks[index - 1];
                      return GestureDetector(
                        onTap: () {
                          context.push('/decks/${deck.id}');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: Colors.grey.shade800,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              deck.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
