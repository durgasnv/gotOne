import 'package:flutter_test/flutter_test.dart';
import 'package:gotone_app/core/models/models.dart';
import 'package:gotone_app/core/models/providers.dart';

Loan sampleLoan() => Loan(
  id: 'loan',
  requestId: 'request',
  offerId: 'offer',
  requesterId: 'borrower',
  lenderId: 'lender',
  campusId: 'campus',
  itemName: 'Charger',
  category: ItemCategory.chargers,
  borrowDurationMinutes: 120,
  status: LoanStatus.awaitingHandoff,
  createdAt: DateTime(2026),
);

void main() {
  test('timer starts at second handoff confirmation and cannot restart', () {
    final notifier = ActiveLoanNotifier(sampleLoan());
    addTearDown(notifier.dispose);
    final start = DateTime(2026, 10, 17, 12);
    notifier.confirmHandoff(borrower: true, now: start);
    expect(notifier.state!.status, LoanStatus.awaitingHandoff);
    expect(notifier.state!.dueAt, isNull);
    notifier.confirmHandoff(
      borrower: false,
      now: start.add(const Duration(minutes: 5)),
    );
    expect(notifier.state!.status, LoanStatus.active);
    expect(notifier.state!.dueAt, start.add(const Duration(minutes: 125)));
    notifier.confirmHandoff(
      borrower: true,
      now: start.add(const Duration(hours: 1)),
    );
    expect(notifier.state!.dueAt, start.add(const Duration(minutes: 125)));
  });

  test('return requires agreed point and both participants', () {
    final notifier = ActiveLoanNotifier(
      sampleLoan().copyWith(status: LoanStatus.active),
    );
    addTearDown(notifier.dispose);
    notifier.confirmReturn(borrower: true);
    expect(notifier.state!.borrowerConfirmedReturn, isFalse);
    notifier.update(
      (l) => l.copyWith(
        agreedReturnPoint: 'Library',
        returnPointAcknowledged: true,
      ),
    );
    notifier.confirmReturn(borrower: true);
    expect(notifier.state!.status, LoanStatus.returnPending);
    notifier.confirmReturn(borrower: false);
    expect(notifier.state!.status, LoanStatus.completed);
    expect(notifier.state!.bothConfirmedReturn, isTrue);
  });

  test('disputed and completed loans reject confirmation actions', () {
    for (final status in [LoanStatus.completed, LoanStatus.disputed]) {
      final loan = sampleLoan().copyWith(status: status);
      final notifier = ActiveLoanNotifier(loan);
      notifier.confirmHandoff(borrower: true);
      notifier.confirmReturn(borrower: true);
      expect(identical(notifier.state, loan), isTrue);
      notifier.dispose();
    }
  });

  test('marking notifications read again does not emit another update', () {
    final notifier = NotificationsNotifier([
      AppNotification(
        id: 'n',
        type: 'offer',
        title: 'Offer',
        createdAt: DateTime(2026),
      ),
    ]);
    addTearDown(notifier.dispose);
    notifier.markAllRead();
    final read = notifier.state;
    notifier.markAllRead();
    expect(identical(notifier.state, read), isTrue);
  });
}
