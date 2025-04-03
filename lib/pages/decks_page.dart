import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/decks_provider.dart';

class DecksPage extends ConsumerWidget {
  const DecksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decksAsync = ref.watch(decksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Decks',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: decksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (decks) => _buildDecksGrid(context, ref, decks),
        ),
      ),
    );
  }

  Widget _buildDecksGrid(BuildContext context, WidgetRef ref, List<DeckItem> decks) {
    return Column(
      children: [
        const SizedBox(height: 16),
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
                  return _buildAddDeckTile(ref, context);
                }
                final deck = decks[index - 1];
                return _buildDeckTile(ref, context, deck);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddDeckTile(WidgetRef ref, BuildContext context) {
    return GestureDetector(
      onTap: () => _createNewDeck(ref, context),
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
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _buildDeckTile(WidgetRef ref, BuildContext context, DeckItem deck) {
    return GestureDetector(
      onTap: () {
        ref.read(decksProvider.notifier).curDeck = deck.id;
        Navigator.pop(context);
      },
      onLongPress: () => _confirmDeleteDeck(ref, context, deck),
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

  Future<void> _createNewDeck(WidgetRef ref, BuildContext context) async {
    final newDeckName = await showDialog<String>(
      context: context,
      builder: (context) {
        final TextEditingController _deckNameController = TextEditingController();
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
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.teal),
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
                final text = _deckNameController.text.trim();
                if (text.isNotEmpty) Navigator.pop(context, text);
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
      try {
        await ref.read(decksProvider.notifier).addDeck(newDeckName);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create deck: $e')));
      }
    }
  }

  void _confirmDeleteDeck(WidgetRef ref, BuildContext context, DeckItem deck) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${deck.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Add deleteDeck method to your DecksNotifier first
                await ref.read(decksProvider.notifier).deleteDeck(deck.id);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete deck: $e')));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}