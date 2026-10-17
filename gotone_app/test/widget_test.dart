import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotone_app/main.dart';
import 'package:gotone_app/core/models/providers.dart';
import 'package:gotone_app/core/router.dart';
import 'package:gotone_app/core/theme/app_theme.dart';
import 'package:gotone_app/features/home/home_screen.dart';

Future<void> advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));
  await tester.pump();
}

void main() {
  testWidgets('onboarding validates campus email and saves profile edits', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    appRouter.go('/');
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const GotOneApp()),
    );
    await advance(tester);
    await tester.tap(find.text("Let's go →"));
    await advance(tester);
    await tester.enterText(find.byType(TextField), 'wrong@example.com');
    await tester.tap(find.text('Continue in demo'));
    await advance(tester);
    expect(
      find.text('Use your @bvrithyderabad.edu.in email 🎓'),
      findsOneWidget,
    );
    await tester.enterText(
      find.byType(TextField),
      'student@bvrithyderabad.edu.in',
    );
    await tester.tap(find.text('Continue in demo'));
    await advance(tester);
    await advance(tester);
    expect(find.text('Demo campus profile 🎓\nWho are you?'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'Mira');
    await tester.tap(find.text('Enter campus 🏫'));
    await advance(tester);
    expect(container.read(currentUserProvider)!.displayName, 'Mira');
    expect(
      container.read(currentUserProvider)!.email,
      'student@bvrithyderabad.edu.in',
    );
    expect(find.text('Campus feed'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await advance(tester);
  });

  testWidgets(
    'offers save and can be withdrawn; accepted loans reach completion',
    (tester) async {
      tester.view.physicalSize = const Size(400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      appRouter.go('/request/r1');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const GotOneApp(),
        ),
      );
      await advance(tester);
      await tester.tap(find.text("I've got this! ✋"));
      await advance(tester);
      await tester.enterText(
        find.byType(TextField),
        'Available by the library',
      );
      await tester.tap(find.text('Send offer'));
      await advance(tester);
      expect(
        container.read(sentOffersProvider)['r1']!.note,
        'Available by the library',
      );
      await tester.tap(find.text('Withdraw offer'));
      await advance(tester);
      expect(container.read(sentOffersProvider), isEmpty);
      appRouter.go('/request/r_mine');
      await advance(tester);
      expect(find.textContaining('CSE-B'), findsNothing);
      await tester.tap(find.text('Accept Aanya ✓'));
      await advance(tester);
      Future<void> tap(String label) async {
        await tester.ensureVisible(find.text(label).first);
        await tester.tap(find.text(label).first);
        await advance(tester);
      }

      await tap('Confirm handoff 🤝');
      expect(container.read(activeLoanProvider)!.dueAt, isNull);
      await tap('Demo: Aanya confirms handoff');
      expect(container.read(activeLoanProvider)!.dueAt, isNotNull);
      await tap('Propose return point');
      await tester.enterText(find.byType(TextField), 'Library entrance');
      await tester.tap(find.text('Propose'));
      await advance(tester);
      await advance(tester);
      await tap('Agree to return point');
      await tap('Item returned 🔁');
      expect(container.read(completedLoansProvider), isEmpty);
      await tap('Demo: Aanya confirms return');
      expect(container.read(completedLoansProvider), hasLength(1));
      expect(find.text('Loan complete!'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await advance(tester);
    },
  );

  testWidgets(
    'posting preserves selected duration, needed-by, and private location',
    (tester) async {
      tester.view.physicalSize = const Size(400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      appRouter.go('/app');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const GotOneApp(),
        ),
      );
      await advance(tester);
      await advance(tester);
      await tester.tap(find.text('+'));
      await advance(tester);
      await tester.enterText(find.byType(TextField).at(0), 'HDMI cable');
      await tester.tap(find.text('🧮 Tech').last);
      await tester.ensureVisible(find.text('Library').last);
      await tester.tap(find.text('Library').last);
      await tester.ensureVisible(find.byType(TextField).at(2));
      await tester.enterText(find.byType(TextField).at(2), 'Desk 42');
      for (final label in ['1 hr', '3 hrs', 'Post request 🚀']) {
        await tester.ensureVisible(find.text(label).first);
        await tester.tap(find.text(label).first);
        await tester.pump();
      }
      await advance(tester);
      final request = container.read(myRequestsProvider).first;
      expect(request.itemName, 'HDMI cable');
      expect(request.borrowDurationMinutes, 180);
      expect(request.zone, 'Library');
      expect(
        request.neededBy.difference(DateTime.now()).inMinutes,
        inInclusiveRange(58, 60),
      );
      expect(container.read(privateHandoffProvider)[request.id], 'Desk 42');
      expect(find.text('My activity'), findsOneWidget);
      expect(find.textContaining('Desk 42'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await advance(tester);
    },
  );

  testWidgets('public cards do not show section or roll number', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final request = container.read(campusRequestsProvider).first;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: RequestCard(request: request, onTap: () {}),
        ),
      ),
    );
    expect(find.text('Aanya'), findsOneWidget);
    expect(find.textContaining('CSE-B'), findsNothing);
    expect(find.textContaining('24WH'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
