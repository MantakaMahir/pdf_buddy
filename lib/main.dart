import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_buddy/features/landing_page.dart';
import 'package:pdf_buddy/utils/theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'PDF Buddy',
      theme: AppTheme.theme,
      home: const LandingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
