import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  runApp(
    // ProviderScope is required — it's the root of all Riverpod providers
    const ProviderScope(
      child: BaalShravyaApp(),
    ),
  );
}