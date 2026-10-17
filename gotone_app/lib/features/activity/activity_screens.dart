import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/models.dart';
import '../../core/models/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets.dart';
import '../home/home_screen.dart';

// ---------------------------------------------------------------------------
// Activity Screen
// ---------------------------------------------------------------------------

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  int _seg = 0; // 0=Requests, 1=Lending, 2=Borrowing, 3=Done

  @override
  Widget build(BuildContext context) {
    final myReqs = ref.watch(myRequestsProvider);
    final myOffers = ref.watch(myOffersProvider);
    final activeLoan = ref.watch(activeLoanProvider);
    final done = ref.watch(completedLoansProvider);

    final lendingLoans =
        activeLoan != null &&
            activeLoan.lenderId == 'uid_durga' &&
            activeLoan.status != LoanStatus.completed
        ? [activeLoan]
        : <Loan>[];

    final borrowingLoans =
        activeLoan != null &&
            activeLoan.requesterId == 'uid_durga' &&
            activeLoan.status != LoanStatus.completed
        ? [activeLoan]
        : <Loan>[];

    final segments = ['Requests', 'Lending', 'Borrowing', 'Done'];
    final lists = [myReqs, lendingLoans, borrowingLoans, done];

    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          backgroundColor: AppColors.background,
          title: Text('My activity'),
          floating: true,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: _SegControl(
              options: segments,
              selected: _seg,
              onSelect: (i) => setState(() => _seg = i),
            ),
          ),
        ),
        if (lists[_seg].isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(segment: segments[_seg]),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((_, i) {
                final item = lists[_seg][i];
                if (_seg == 0) {
                  // My requests
                  final req = item as ItemRequest;
                  final offerCount = myOffers
                      .where((o) => o.requestId == req.id)
                      .length;
                  return RequestCard(
                    request: req,
                    mine: true,
                    offerCount: offerCount,
                    onTap: () => context.push('/request/${req.id}'),
                  );
                } else {
                  // Loan rows
                  final loan = item as Loan;
                  return _LoanRow(
                    loan: loan,
                    isDone: _seg == 3,
                    onTap: _seg != 3 ? () => context.push('/loan') : null,
                  );
                }
              }, childCount: lists[_seg].length),
            ),
          ),
      ],
    );
  }
}

class _LoanRow extends StatelessWidget {
  const _LoanRow({required this.loan, required this.isDone, this.onTap});
  final Loan loan;
  final bool isDone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final partner = loan.lenderId == 'uid_durga'
        ? loan.borrowerDisplayName
        : loan.lenderDisplayName;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            CategoryIcon(category: loan.category),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loan.itemName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onLight,
                    ),
                  ),
                  Text(
                    'with $partner · ${isDone ? 'completed ✓' : 'in progress'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0x99000000),
                    ),
                  ),
                ],
              ),
            ),
            if (!isDone)
              const Icon(Icons.chevron_right_rounded, color: AppColors.onLight),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.segment});
  final String segment;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🌱', style: TextStyle(fontSize: 54)),
        const SizedBox(height: 12),
        const Text(
          'Nothing here yet',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onDark,
          ),
        ),
        Text(
          'Your ${segment.toLowerCase()} will show up here.',
          style: const TextStyle(fontSize: 14, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _SegControl extends StatelessWidget {
  const _SegControl({
    required this.options,
    required this.selected,
    required this.onSelect,
  });
  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(99),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(options.length, (i) {
            final active = selected == i;
            return GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  options[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active ? AppColors.onLight : const Color(0xFFBBBBBB),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifications Screen
// ---------------------------------------------------------------------------

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    // Mark all read on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).markAllRead();
    });

    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          backgroundColor: AppColors.background,
          title: Text('Notifications'),
          floating: true,
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(left: 20, bottom: 4),
            child: Text(
              'Simulated for this prototype',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _NotifCard(n: notifications[i]),
              childCount: notifications.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _NotifCard extends StatelessWidget {
  const _NotifCard({required this.n});
  final AppNotification n;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: n.isUnread ? const Color(0xFFF1EEFF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(n.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              n.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onLight,
              ),
            ),
          ),
          Text(
            _timeAgo(n.createdAt),
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  static String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return 'Yesterday';
  }
}

// ---------------------------------------------------------------------------
// Profile Screen
// ---------------------------------------------------------------------------

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          backgroundColor: AppColors.background,
          title: Text('Profile'),
          floating: true,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: AppColors.lavender,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🦊', style: TextStyle(fontSize: 44)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.displayName ?? 'Student',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onDark,
                  ),
                ),
                Text(
                  '${user?.classSection ?? ''} · BVRIT Hyderabad',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: AppColors.muted),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      '✓ Demo campus member',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Stats row
                Row(
                  children: [
                    _StatCard(value: '${user?.lentCount ?? 0}', label: 'lent'),
                    const SizedBox(width: 8),
                    _StatCard(
                      value: '${user?.borrowedCount ?? 0}',
                      label: 'borrowed',
                    ),
                    const SizedBox(width: 8),
                    const _StatCard(value: '4.9', label: 'trust'),
                  ],
                ),
                const SizedBox(height: 16),
                // Privacy notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔒 Privacy',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onDark,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Roll number and exact handoff spots are only visible to matched participants.',
                        style: TextStyle(fontSize: 13, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Roll & section display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileField(label: 'Email', value: user?.email ?? ''),
                      const Divider(color: Color(0xFF2E2E33)),
                      _ProfileField(
                        label: 'Roll number',
                        value: user?.rollNumber ?? '',
                        private: true,
                      ),
                      const Divider(color: Color(0xFF2E2E33)),
                      _ProfileField(
                        label: 'Class / section',
                        value: user?.classSection ?? '',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GotOneButton(
                  label: 'Replay onboarding',
                  color: const Color(0xFF26262B),
                  onPressed: () => context.go('/'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.onLight,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0x99000000)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.value,
    this.private = false,
  });
  final String label;
  final String value;
  final bool private;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          Row(
            children: [
              if (private) ...[
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 12,
                  color: AppColors.muted,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
