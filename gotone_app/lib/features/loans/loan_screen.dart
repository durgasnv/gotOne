import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/models.dart';
import '../../core/models/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets.dart';

/// Full-screen loan tracking screen — mirrors the HTML prototype's `loan` view.
class LoanScreen extends ConsumerStatefulWidget {
  const LoanScreen({super.key});

  @override
  ConsumerState<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends ConsumerState<LoanScreen> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final loan = ref.read(activeLoanProvider);
      if (loan?.dueAt != null && mounted) {
        setState(() {
          _remaining = loan!.dueAt!.difference(DateTime.now());
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    if (d.isNegative) return '00:00:00';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final loan = ref.watch(activeLoanProvider);

    if (loan == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/app/activity'),
          ),
        ),
        body: const Center(
          child: Text(
            'No active loan',
            style: TextStyle(color: AppColors.muted),
          ),
        ),
      );
    }

    final isBorrower = loan.requesterId == 'uid_durga';
    final partner = isBorrower
        ? loan.lenderDisplayName
        : loan.borrowerDisplayName;

    final steps = [
      'Request posted',
      'Offer accepted',
      'Handoff confirmed',
      'Borrowing active',
      'Return pending',
      'Completed 🎉',
    ];

    final currentStep = _loanStep(loan);
    if (loan.dueAt != null) _remaining = loan.dueAt!.difference(DateTime.now());

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.background,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go('/app/activity'),
                ),
                title: const Text('Loan tracker'),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        '${loan.category.emoji} ${loan.itemName}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                          color: AppColors.onDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${isBorrower ? 'Borrowing from' : 'Lending to'} $partner',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Countdown (shown when active)
                      if (loan.status == LoanStatus.active ||
                          loan.status == LoanStatus.returnPending) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.sky,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            loan.dueAt != null ? _fmt(_remaining) : '--:--:--',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w300,
                              letterSpacing: -3,
                              color: AppColors.onLight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Private handoff card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🔒 Private handoff point',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.onDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              loan.exactHandoffPoint.isEmpty
                                  ? 'Visible only to you two'
                                  : loan.exactHandoffPoint,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _ConfirmPill(
                                  label: 'You',
                                  confirmed: isBorrower
                                      ? loan.borrowerConfirmedHandoff
                                      : loan.lenderConfirmedHandoff,
                                ),
                                const SizedBox(width: 8),
                                _ConfirmPill(
                                  label: partner,
                                  confirmed: isBorrower
                                      ? loan.lenderConfirmedHandoff
                                      : loan.borrowerConfirmedHandoff,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Timeline
                      _Timeline(steps: steps, current: currentStep),
                      const SizedBox(height: 18),

                      // Action button(s)
                      ..._actionButtons(context, loan, isBorrower, partner),

                      const SizedBox(height: 12),
                      GotOneButton(
                        label: '🚩 Report an issue',
                        color: const Color(0xFF26262B),
                        onPressed:
                            loan.status == LoanStatus.completed ||
                                loan.status == LoanStatus.disputed
                            ? null
                            : _reportIssue,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_showConfetti) const ConfettiOverlay(child: SizedBox.expand()),
      ],
    );
  }

  int _loanStep(Loan loan) {
    switch (loan.status) {
      case LoanStatus.awaitingHandoff:
        return loan.borrowerConfirmedHandoff || loan.lenderConfirmedHandoff
            ? 2
            : 1;
      case LoanStatus.active:
        return 3;
      case LoanStatus.returnPending:
        return 4;
      case LoanStatus.completed:
        return 5;
      default:
        return 1;
    }
  }

  List<Widget> _actionButtons(
    BuildContext context,
    Loan loan,
    bool isBorrower,
    String partner,
  ) {
    final myConfirmedHandoff = isBorrower
        ? loan.borrowerConfirmedHandoff
        : loan.lenderConfirmedHandoff;

    if (loan.status == LoanStatus.awaitingHandoff) {
      return [
        GotOneButton(
          label: myConfirmedHandoff
              ? 'Waiting for $partner…'
              : 'Confirm handoff 🤝',
          onPressed: myConfirmedHandoff ? null : () => _confirmHandoff(),
        ),
        if (myConfirmedHandoff) ...[
          const SizedBox(height: 10),
          GotOneButton(
            label: 'Demo: $partner confirms handoff',
            color: AppColors.lavender,
            onPressed: () => ref
                .read(activeLoanProvider.notifier)
                .confirmHandoff(borrower: !isBorrower),
          ),
        ],
        const SizedBox(height: 8),
        const Text(
          'Countdown starts only after both confirm.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.muted),
        ),
      ];
    }

    if (loan.status == LoanStatus.active ||
        loan.status == LoanStatus.returnPending) {
      final mine = isBorrower
          ? loan.borrowerConfirmedReturn
          : loan.lenderConfirmedReturn;
      final theirs = isBorrower
          ? loan.lenderConfirmedReturn
          : loan.borrowerConfirmedReturn;
      return [
        Text(
          '🔒 Return point: ${loan.agreedReturnPoint ?? "Not agreed yet"}',
          style: const TextStyle(color: AppColors.muted),
        ),
        if (loan.agreedReturnPoint == null)
          GotOneButton(
            label: 'Propose return point',
            onPressed: _setReturnPoint,
          ),
        if (loan.agreedReturnPoint != null && !loan.returnPointAcknowledged)
          GotOneButton(
            label: isBorrower
                ? 'Agree to return point'
                : 'Demo: borrower agrees to return point',
            onPressed: () => ref
                .read(activeLoanProvider.notifier)
                .update((l) => l.copyWith(returnPointAcknowledged: true)),
          ),
        const SizedBox(height: 12),
        GotOneButton(
          label: mine
              ? 'Waiting for $partner…'
              : isBorrower
              ? 'Item returned 🔁'
              : 'Confirm return received ✓',
          color: AppColors.mint,
          onPressed: mine || !loan.returnPointAcknowledged
              ? null
              : () => _confirmReturnFor(isBorrower),
        ),
        if (mine && !theirs) ...[
          const SizedBox(height: 10),
          GotOneButton(
            label: 'Demo: $partner confirms return',
            color: AppColors.lavender,
            onPressed: () => _confirmReturnFor(!isBorrower),
          ),
        ],
      ];
    }
    if (loan.status == LoanStatus.disputed) {
      return [
        const Text(
          '🚩 Issue recorded in this demo. No moderator has been contacted.',
          style: TextStyle(color: AppColors.accent),
        ),
      ];
    }

    if (loan.status == LoanStatus.completed) {
      return [
        const Column(
          children: [
            Text('🏆', style: TextStyle(fontSize: 54)),
            SizedBox(height: 8),
            Text(
              'Loan complete!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.onDark,
              ),
            ),
          ],
        ),
      ];
    }

    return [];
  }

  void _confirmHandoff() {
    final loan = ref.read(activeLoanProvider);
    if (loan == null) return;
    ref
        .read(activeLoanProvider.notifier)
        .confirmHandoff(borrower: loan.requesterId == 'uid_durga');
  }

  Future<void> _setReturnPoint() async {
    final controller = TextEditingController();
    final point = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agree a return point'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.onLight),
          decoration: const InputDecoration(hintText: 'e.g. Library entrance'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(ctx, controller.text.trim());
              }
            },
            child: const Text('Propose'),
          ),
        ],
      ),
    );
    // The dialog finishes its closing animation before its controller is disposed.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
    if (!mounted || point == null) return;
    ref
        .read(activeLoanProvider.notifier)
        .update((l) => l.copyWith(agreedReturnPoint: point));
  }

  void _confirmReturnFor(bool borrower) {
    ref.read(activeLoanProvider.notifier).confirmReturn(borrower: borrower);
    final loan = ref.read(activeLoanProvider);
    if (loan?.status != LoanStatus.completed) return;
    ref.read(completedLoansProvider.notifier).add(loan!);
    ref
        .read(notificationsProvider.notifier)
        .add(
          AppNotification(
            id: 'done_${loan.id}',
            type: 'loan_complete',
            title: 'Loan completed: ${loan.itemName}',
            emoji: '🎉',
            createdAt: DateTime.now(),
          ),
        );
    setState(() => _showConfetti = true);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _showConfetti = false);
    });
  }

  Future<void> _reportIssue() async {
    final reason = TextEditingController();
    final explanation = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report an issue'),
        content: TextField(
          controller: reason,
          maxLines: 3,
          style: const TextStyle(color: AppColors.onLight),
          decoration: const InputDecoration(hintText: 'Describe what happened'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (reason.text.trim().isNotEmpty) {
                Navigator.pop(ctx, reason.text.trim());
              }
            },
            child: const Text('Record issue'),
          ),
        ],
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    reason.dispose();
    if (!mounted || explanation == null) return;
    ref
        .read(activeLoanProvider.notifier)
        .update((l) => l.copyWith(status: LoanStatus.disputed));
    ref
        .read(notificationsProvider.notifier)
        .add(
          AppNotification(
            id: 'issue_${DateTime.now().microsecondsSinceEpoch}',
            type: 'dispute',
            title: 'Demo issue recorded: $explanation',
            emoji: '🚩',
            createdAt: DateTime.now(),
          ),
        );
  }
}

// ---------------------------------------------------------------------------
// Timeline widget
// ---------------------------------------------------------------------------

class _Timeline extends StatelessWidget {
  const _Timeline({required this.steps, required this.current});
  final List<String> steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (i) {
        final done = i < current;
        final active = i == current;
        return _TimelineRow(
          label: steps[i],
          done: done,
          active: active,
          isLast: i == steps.length - 1,
        );
      }),
    );
  }
}

class _TimelineRow extends StatefulWidget {
  const _TimelineRow({
    required this.label,
    required this.done,
    required this.active,
    required this.isLast,
  });

  final String label;
  final bool done;
  final bool active;
  final bool isLast;

  @override
  State<_TimelineRow> createState() => _TimelineRowState();
}

class _TimelineRowState extends State<_TimelineRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.active) _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                const SizedBox(height: 6),
                AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) {
                    final scale = widget.active ? 1.0 + _ctrl.value * 0.5 : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.done
                              ? AppColors.mint
                              : widget.active
                              ? AppColors.yellow
                              : AppColors.surface,
                          border: Border.all(
                            color: widget.done || widget.active
                                ? Colors.transparent
                                : AppColors.surface,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (!widget.isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      color: widget.done ? AppColors.mint : AppColors.surface,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: widget.active ? FontWeight.w700 : FontWeight.w600,
                  color: widget.done
                      ? AppColors.onDark
                      : widget.active
                      ? AppColors.onDark
                      : const Color(0xFF6F6F78),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Confirmation pill
// ---------------------------------------------------------------------------

class _ConfirmPill extends StatelessWidget {
  const _ConfirmPill({required this.label, required this.confirmed});
  final String label;
  final bool confirmed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: confirmed ? AppColors.mint : Colors.white,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '$label ${confirmed ? '✓' : '…'}',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.onLight,
        ),
      ),
    );
  }
}
