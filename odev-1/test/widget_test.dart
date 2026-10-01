import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demokrasi_app/main.dart';

void main() {
  testWidgets('Comprehensive Zero-Overflow & Navigation Verification Test', (WidgetTester tester) async {
    // Standard phone dimensions (390 x 844, similar to modern smartphones)
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // 1. Initial Launch
    await tester.pumpWidget(const DemokrasiApp());
    await tester.pumpAndSettle();
    expect(find.byType(DemokrasiApp), findsOneWidget);
    expect(find.text('DEMOKRASİ'), findsOneWidget);

    // Verify Tab 1 (Konular)
    expect(find.text('Tümü'), findsOneWidget);
    expect(find.text('Yeni Yasa'), findsOneWidget);

    // Filter switching
    await tester.tap(find.text('Oylamada'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Yürürlükte'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Veto'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tümü'));
    await tester.pumpAndSettle();

    // 2. Tab 2: İnsan Grafı
    await tester.tap(find.text('İnsan Grafı'));
    await tester.pumpAndSettle();
    expect(find.byType(CustomPaint), findsWidgets);

    // 3. Tab 3: Bilirkişi
    await tester.tap(find.text('Bilirkişi'));
    await tester.pumpAndSettle();
    expect(find.text('Kural 6: Normlar Hiyerarşisi Ontolojisi'), findsOneWidget);

    // 4. Tab 4: Defter
    await tester.tap(find.text('Defter'));
    await tester.pumpAndSettle();
    expect(find.text('Dağıtık Defter & Blok Gezgini'), findsOneWidget);

    // 5. Tab 5: Kimlik
    await tester.tap(find.text('Kimlik'));
    await tester.pumpAndSettle();
    expect(find.text('Kural 3: Sistem Tarafında Tutulan Gerçek Kimlik'), findsOneWidget);

    // 6. Test Settings & Scenario Sheet
    await tester.tap(find.byIcon(Icons.tune).first);
    await tester.pumpAndSettle();
    expect(find.text('🎭 Hoca Senaryoları'), findsOneWidget);
    expect(find.text('🛠️ Manuel Kontroller'), findsOneWidget);

    // Switch to Manuel Kontroller
    await tester.tap(find.text('🛠️ Manuel Kontroller'));
    await tester.pumpAndSettle();

    // Close Settings Sheet
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    // Return to Tab 1 (Konular)
    await tester.tap(find.text('Konular'));
    await tester.pumpAndSettle();

    // Test Tyranny Simulator Modal
    final simButton = find.text('Simüle Et');
    if (simButton.evaluate().isNotEmpty) {
      await tester.tap(simButton);
      await tester.pumpAndSettle();
      expect(find.text('Anladım, Kapat'), findsOneWidget);
      await tester.tap(find.text('Anladım, Kapat'));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('Narrow screen test (360x640) for zero overflow', (WidgetTester tester) async {
    // Narrow small phone dimensions
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const DemokrasiApp());
    await tester.pumpAndSettle();

    // Verify all components rendered cleanly with zero RenderFlex overflow
    expect(find.text('DEMOKRASİ'), findsOneWidget);
    expect(find.text('Tümü'), findsOneWidget);
  });
}
