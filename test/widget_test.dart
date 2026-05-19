import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:grace_scanner/app.dart';

void main() {
  testWidgets('App launches and shows home screen', (tester) async {
    // Suppress google_fonts async errors in test (fonts aren't bundled as assets)
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exception.toString().contains('GoogleFonts')) return;
      originalOnError?.call(details);
    };

    await tester.runAsync(() async {
      await tester.pumpWidget(
        const ProviderScope(child: ScanFlowApp()),
      );
    });

    expect(find.text('ScanFlow'), findsOneWidget);

    // Restore
    FlutterError.onError = originalOnError;
  });
}
