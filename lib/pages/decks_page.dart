import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:holo/pages/details_page.dart';
import '../services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DecksPage extends ConsumerWidget  {
  const DecksPage({super.key}); 

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionAsync = ref.watch(collectionProvider);
    final cardqty = ref.watch(collectionProvider).value?.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      'My Decks',
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
          ],
        ),
      ),
    );
  }

}

