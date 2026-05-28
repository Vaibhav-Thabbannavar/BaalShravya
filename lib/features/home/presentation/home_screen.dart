import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import 'anm_home_screen.dart';
import 'parent_home_screen.dart';
import 'admin_home_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    switch (user?.role) {
      case 'anm':
        return const AnmHomeScreen();
      case 'parent':
        return const ParentHomeScreen();
      case 'admin':
        return const AdminHomeScreen();
      default:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
    }
  }
}