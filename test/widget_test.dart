import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_buddy/features/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('landing page offers merge and split tools', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LandingPage())),
    );

    expect(find.text('Merge PDFs'), findsOneWidget);
    expect(find.text('Split a PDF'), findsOneWidget);
  });
}
