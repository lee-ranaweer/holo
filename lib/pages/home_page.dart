import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key}); 
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value!;

    return Scaffold(
      appBar: AppBar(title: Text(user.email!)),
    );
  }
}
