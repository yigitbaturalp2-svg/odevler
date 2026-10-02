import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demokrasi_app/main.dart';

void main() {
  testWidgets('Comprehensive Zero-Overflow & Navigation Verification Test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // 1. Initial Launch
    await tester.pumpWidget(const DemokrasiApp());
    await tester.pumpAndSettle();
    expect(find.byType(DemokrasiApp), findsOneWidget);
    expect(find.text('DEMOKRASİ'), findsOneWidget);

    // Filter switching
    expect(find.text('Tümü'), findsWidgets);
    expect(find.text('Oylamada'), findsWidgets);
    expect(find.text('Yürürlükte'), findsWidgets);
    expect(find.text('Veto'), findsWidgets);

    await tester.tap(find.text('Oylamada').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tümü').first);
    await tester.pumpAndSettle();

    // 2. Open First Proposal Detail Screen
    final detailButton = find.text('İncele & Oyla').first;
    expect(detailButton, findsOneWidget);
    await tester.tap(detailButton);
    await tester.pumpAndSettle();

    // Verify Proposal Detail view top sections
    expect(find.textContaining('Yasa Metni'), findsWidgets);
    expect(find.textContaining('Metin Değişiklik Önergesi'), findsWidgets);
    expect(find.textContaining('Bağlı Alt Maddeler'), findsWidgets);

    // Scroll down in detail screen
    await tester.drag(find.byType(ListView).last, const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.textContaining('Hukuki Denetim'), findsWidgets);
    expect(find.textContaining('Müzakere Defteri'), findsWidgets);

    // Scroll to voting section
    await tester.drag(find.byType(ListView).last, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.textContaining('Karesel Oylama'), findsWidgets);

    // Test quadratic vote button (+1 Oy Ver (1 VC))
    final voteButton = find.textContaining('+1 Oy Ver');
    if (voteButton.evaluate().isNotEmpty) {
      await tester.tap(voteButton.first);
      await tester.pumpAndSettle();
    }

    // Go back to main list
    final backButton = find.byType(BackButton);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton.first);
    } else {
      await tester.pageBack();
    }
    await tester.pumpAndSettle();

    // 3. Tab 2: Mevzuat
    await tester.tap(find.text('Mevzuat'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Normlar Hiyerarşisi'), findsWidgets);
    expect(find.textContaining('Bilirkişi'), findsWidgets);

    // 4. Tab 3: Defter
    await tester.tap(find.text('Defter'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Dağıtık Defter'), findsWidgets);
    expect(find.textContaining('Yeni Blok Kaz'), findsWidgets);

    // 5. Tab 4: Kimlik
    await tester.tap(find.text('Kimlik'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Gerçek Kimlik (KYC)'), findsWidgets);
    expect(find.textContaining('ZKP Rumuzu'), findsWidgets);

    // Test persona switch
    await tester.tap(find.textContaining('Prof. Dr. İlker Akman').first);
    await tester.pumpAndSettle();

    // Return to Teklifler tab
    await tester.tap(find.text('Teklifler'));
    await tester.pumpAndSettle();
  });

  testWidgets('Narrow screen test (360x640) for zero overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const DemokrasiApp());
    await tester.pumpAndSettle();

    expect(find.text('DEMOKRASİ'), findsOneWidget);
    expect(find.text('Tümü'), findsWidgets);
  });
}
