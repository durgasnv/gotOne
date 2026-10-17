import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';

// ---------------------------------------------------------------------------
// Seed data — matches the HTML prototype's S.reqs / S.mine / S.n arrays
// ---------------------------------------------------------------------------

final _seedRequests = <ItemRequest>[
  ItemRequest(
    id: 'r1',
    requesterId: 'uid_aanya',
    campusId: 'bvrit',
    itemName: 'Type-C charger',
    category: ItemCategory.chargers,
    description: 'Laptop at 4% and I have a lab record due. Any 65 W works!',
    zone: 'Block A',
    neededBy: DateTime.now().add(const Duration(minutes: 90)),
    borrowDurationMinutes: 120,
    status: RequestStatus.open,
    createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    requesterDisplayName: 'Aanya',
    requesterSection: 'CSE-B',
  ),
  ItemRequest(
    id: 'r2',
    requesterId: 'uid_rohan',
    campusId: 'bvrit',
    itemName: 'Lab coat (M)',
    category: ItemCategory.lab,
    description: 'Forgot mine at the hostel. Chemistry lab at 2.',
    zone: 'Block C',
    neededBy: DateTime.now().add(const Duration(minutes: 105)),
    borrowDurationMinutes: 180,
    status: RequestStatus.open,
    createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    requesterDisplayName: 'Rohan',
    requesterSection: 'ECE-A',
  ),
  ItemRequest(
    id: 'r3',
    requesterId: 'uid_meher',
    campusId: 'bvrit',
    itemName: 'Umbrella',
    category: ItemCategory.rain,
    description: 'Surprise rain, I have to cross the whole campus 😭',
    zone: 'Canteen',
    neededBy: DateTime.now().add(const Duration(minutes: 5)),
    borrowDurationMinutes: 60,
    status: RequestStatus.open,
    createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
    requesterDisplayName: 'Meher',
    requesterSection: 'IT-C',
  ),
  ItemRequest(
    id: 'r4',
    requesterId: 'uid_kiran',
    campusId: 'bvrit',
    itemName: 'Casio fx-991',
    category: ItemCategory.tech,
    description: 'Exam tomorrow, mine died.',
    zone: 'Library',
    neededBy: DateTime.now().add(const Duration(hours: 8)),
    borrowDurationMinutes: 1440,
    status: RequestStatus.open,
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    requesterDisplayName: 'Kiran',
    requesterSection: 'CSE-A',
  ),
  ItemRequest(
    id: 'r5',
    requesterId: 'uid_sana',
    campusId: 'bvrit',
    itemName: 'Highlighters',
    category: ItemCategory.study,
    description: 'Just need yellow + pink for revision.',
    zone: 'Hostel Row',
    neededBy: DateTime.now().add(const Duration(hours: 6)),
    borrowDurationMinutes: 1440,
    status: RequestStatus.open,
    createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    requesterDisplayName: 'Sana',
    requesterSection: 'AIML-B',
  ),
];

final _myRequest = ItemRequest(
  id: 'r_mine',
  requesterId: 'uid_durga',
  campusId: 'bvrit',
  itemName: 'Scientific calculator',
  category: ItemCategory.tech,
  description: 'Need for the DSA quiz. Condition: any works.',
  zone: 'Block A',
  neededBy: DateTime.now().add(const Duration(hours: 3)),
  borrowDurationMinutes: 120,
  status: RequestStatus.open,
  createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
  requesterDisplayName: 'Durga',
  requesterSection: 'CSE-B',
);

final _seedOffers = <LendOffer>[
  LendOffer(
    id: 'o1',
    requestId: 'r_mine',
    lenderId: 'uid_aanya',
    availability: 'Free now',
    note: "Casio, barely used!",
    status: OfferStatus.pending,
    createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
    lenderDisplayName: 'Aanya',
    lenderSection: 'CSE-B',
    lenderTrustScore: 12,
  ),
  LendOffer(
    id: 'o2',
    requestId: 'r_mine',
    lenderId: 'uid_dev',
    availability: 'After 1 PM',
    note: 'Can meet at the library.',
    status: OfferStatus.pending,
    createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
    lenderDisplayName: 'Dev',
    lenderSection: 'ECE-C',
    lenderTrustScore: 4,
  ),
];

final _seedNotifications = <AppNotification>[
  AppNotification(
    id: 'n1',
    type: 'offer_received',
    title: 'Aanya offered to lend your calculator',
    emoji: '🙋',
    createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
  ),
  AppNotification(
    id: 'n2',
    type: 'due_soon',
    title: 'Return reminder: charger due in 30 min',
    emoji: '⏰',
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  AppNotification(
    id: 'n3',
    type: 'loan_complete',
    title: 'Loan with Rohan completed. +1 trust',
    emoji: '🎉',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    readAt: DateTime.now().subtract(const Duration(hours: 23)),
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All campus requests (excluding the current user's own request).
final campusRequestsProvider =
    StateNotifierProvider<CampusRequestsNotifier, List<ItemRequest>>((ref) {
      return CampusRequestsNotifier(List.from(_seedRequests));
    });

class CampusRequestsNotifier extends StateNotifier<List<ItemRequest>> {
  CampusRequestsNotifier(super.initial);

  void add(ItemRequest r) => state = [r, ...state];
  void remove(String id) => state = state.where((r) => r.id != id).toList();
  void update(ItemRequest updated) =>
      state = state.map((r) => r.id == updated.id ? updated : r).toList();
}

/// The current user's own requests.
final myRequestsProvider =
    StateNotifierProvider<MyRequestsNotifier, List<ItemRequest>>((ref) {
      return MyRequestsNotifier([_myRequest]);
    });

class MyRequestsNotifier extends StateNotifier<List<ItemRequest>> {
  MyRequestsNotifier(super.initial);

  void add(ItemRequest r) => state = [r, ...state];
  void remove(String id) => state = state.where((r) => r.id != id).toList();
  void update(ItemRequest updated) =>
      state = state.map((r) => r.id == updated.id ? updated : r).toList();
}

/// Offers on the current user's requests.
final myOffersProvider =
    StateNotifierProvider<MyOffersNotifier, List<LendOffer>>((ref) {
      return MyOffersNotifier(List.from(_seedOffers));
    });

class MyOffersNotifier extends StateNotifier<List<LendOffer>> {
  MyOffersNotifier(super.initial);

  void add(LendOffer o) => state = [o, ...state];
  void remove(String id) => state = state.where((o) => o.id != id).toList();
}

/// Offers the current user has sent on other requests.
final sentOffersProvider =
    StateNotifierProvider<SentOffersNotifier, Map<String, LendOffer>>((ref) {
      return SentOffersNotifier({});
    });

class SentOffersNotifier extends StateNotifier<Map<String, LendOffer>> {
  SentOffersNotifier(super.initial);

  void add(String requestId, LendOffer offer) =>
      state = {...state, requestId: offer};
  void remove(String requestId) {
    final next = Map<String, LendOffer>.from(state);
    next.remove(requestId);
    state = next;
  }
}

/// Active or in-progress loan for the current user (at most one for the MVP).
final activeLoanProvider = StateNotifierProvider<ActiveLoanNotifier, Loan?>((
  ref,
) {
  return ActiveLoanNotifier(null);
});

class ActiveLoanNotifier extends StateNotifier<Loan?> {
  ActiveLoanNotifier(super.initial);

  void set(Loan l) => state = l;
  void update(Loan Function(Loan) fn) {
    if (state != null) state = fn(state!);
  }

  void confirmHandoff({required bool borrower, DateTime? now}) {
    final loan = state;
    if (loan == null || loan.status != LoanStatus.awaitingHandoff) return;
    var next = loan.copyWith(
      borrowerConfirmedHandoff: borrower ? true : loan.borrowerConfirmedHandoff,
      lenderConfirmedHandoff: borrower ? loan.lenderConfirmedHandoff : true,
    );
    if (next.bothConfirmedHandoff) {
      final started = now ?? DateTime.now();
      next = next.copyWith(
        status: LoanStatus.active,
        startedAt: started,
        dueAt: started.add(Duration(minutes: next.borrowDurationMinutes)),
      );
    }
    state = next;
  }

  void confirmReturn({required bool borrower}) {
    final loan = state;
    if (loan == null ||
        !loan.returnPointAcknowledged ||
        (loan.status != LoanStatus.active &&
            loan.status != LoanStatus.returnPending)) {
      return;
    }
    var next = loan.copyWith(
      borrowerConfirmedReturn: borrower ? true : loan.borrowerConfirmedReturn,
      lenderConfirmedReturn: borrower ? loan.lenderConfirmedReturn : true,
      status: LoanStatus.returnPending,
    );
    if (next.bothConfirmedReturn) {
      next = next.copyWith(status: LoanStatus.completed);
    }
    state = next;
  }

  void clear() => state = null;
}

/// Completed loans for the current user.
final completedLoansProvider =
    StateNotifierProvider<CompletedLoansNotifier, List<Loan>>((ref) {
      return CompletedLoansNotifier([]);
    });

class CompletedLoansNotifier extends StateNotifier<List<Loan>> {
  CompletedLoansNotifier(super.initial);

  void add(Loan l) => state = [l, ...state];
}

/// In-app notifications.
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
      return NotificationsNotifier(List.from(_seedNotifications));
    });

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier(super.initial);

  void add(AppNotification n) => state = [n, ...state];

  void markAllRead() {
    if (!state.any((n) => n.isUnread)) return;
    final now = DateTime.now();
    state = state
        .map(
          (n) => n.readAt != null
              ? n
              : AppNotification(
                  id: n.id,
                  type: n.type,
                  title: n.title,
                  emoji: n.emoji,
                  relatedId: n.relatedId,
                  createdAt: n.createdAt,
                  readAt: now,
                ),
        )
        .toList();
  }

  int get unreadCount => state.where((n) => n.isUnread).length;
}

/// Simple current-user mock (auth screen will update this).
final currentUserProvider = StateProvider<AppUser?>((ref) {
  final now = DateTime(2024);
  return AppUser(
    uid: 'uid_durga',
    email: 'durga@bvrithyderabad.edu.in',
    displayName: 'Durga',
    campusId: 'bvrit',
    verifiedAt: now,
    createdAt: now,
    rollNumber: '24WH1A05XX',
    classSection: 'CSE-B',
    lentCount: 12,
    borrowedCount: 5,
  );
});

// ignore: unused_element
final _epoch = DateTime(2024);

/// Local demo state; production must enforce these boundaries in the backend.
final demoEmailProvider = StateProvider<String>((ref) => '');
final privateHandoffProvider = StateProvider<Map<String, String>>(
  (ref) => {'r_mine': 'Library steps, 2nd pillar'},
);
