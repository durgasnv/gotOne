import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/models.dart';
import '../../core/models/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets.dart';
import '../../core/helpers.dart';

// ---------------------------------------------------------------------------
// Request Detail Screen
// ---------------------------------------------------------------------------

class RequestDetailScreen extends ConsumerStatefulWidget {
  const RequestDetailScreen({super.key, required this.requestId});
  final String requestId;

  @override
  ConsumerState<RequestDetailScreen> createState() =>
      _RequestDetailScreenState();
}

class _RequestDetailScreenState extends ConsumerState<RequestDetailScreen> {
  bool _showOfferSheet = false;
  String _availability = 'Now';
  final _noteCtrl = TextEditingController();

  ItemRequest? _find() {
    final campus = ref.read(campusRequestsProvider);
    final mine = ref.read(myRequestsProvider);
    try {
      return [...campus, ...mine].firstWhere((r) => r.id == widget.requestId);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Color _bg(ItemRequest r) {
    if (r.isUrgent) return const Color(0xFFFFB199);
    switch (r.category) {
      case ItemCategory.chargers:
        return AppColors.mint;
      case ItemCategory.study:
        return AppColors.lavender;
      case ItemCategory.lab:
        return AppColors.yellow;
      case ItemCategory.rain:
        return AppColors.sky;
      case ItemCategory.tech:
        return AppColors.card;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(myRequestsProvider);
    ref.watch(campusRequestsProvider);
    final request = _find();
    if (request == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Request')),
        body: const Center(child: Text('Request not found')),
      );
    }

    final isMine = request.requesterId == 'uid_durga';
    final sentOffers = ref.watch(sentOffersProvider);
    final myOffer = sentOffers[widget.requestId];
    final myOffers = ref.watch(myOffersProvider);
    final offersOnMine = myOffers
        .where((o) => o.requestId == widget.requestId)
        .toList();

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
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go('/app'),
                ),
                title: const Text('Request'),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category icon
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: _bg(request),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Center(
                          child: Text(
                            request.category.emoji,
                            style: const TextStyle(fontSize: 50),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        request.itemName,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.5,
                          color: AppColors.onDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isMine
                            ? 'Your request'
                            : 'Asked by ${request.requesterDisplayName}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        request.description,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.onDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        children: [
                          ItemTag(
                            '📍 ${request.zone} (exact spot shared after match)',
                          ),
                          ItemTag(
                            '⏳ ${durLabel(request.borrowDurationMinutes)}',
                          ),
                          ItemTag('🕒 by ${timeLabel(request.neededBy)}'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (isMine) ...[
                        // My request — show offers
                        Text(
                          '${offersOnMine.length} offers 🙌',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Compare, then accept exactly one.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (offersOnMine.isEmpty)
                          _EmptyOffers()
                        else
                          ...offersOnMine.map(
                            (o) => _OfferCard(
                              offer: o,
                              onAccept: () => _accept(context, request, o),
                            ),
                          ),
                      ] else if (myOffer != null) ...[
                        // Sent an offer — show pending state
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.yellow,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Offer pending ⏳',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onLight,
                                ),
                              ),
                              Text(
                                'You said: ${myOffer.availability}${myOffer.note.isNotEmpty ? ' · "${myOffer.note}"' : ''}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.onLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        GotOneButton(
                          label: 'Withdraw offer',
                          color: const Color(0xFF26262B),
                          onPressed: () {
                            ref
                                .read(sentOffersProvider.notifier)
                                .remove(widget.requestId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Offer withdrawn')),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        // Demo accept simulation
                        GotOneButton(
                          label:
                              '🧪 Demo: pretend ${request.requesterDisplayName} accepts',
                          color: AppColors.lavender,
                          onPressed: () => _simulateAccepted(context, request),
                        ),
                      ] else ...[
                        GotOneButton(
                          label: "I've got this! ✋",
                          onPressed: () =>
                              setState(() => _showOfferSheet = true),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Offer sheet overlay
        if (_showOfferSheet)
          _OfferSheet(
            availability: _availability,
            noteCtrl: _noteCtrl,
            onAvChange: (v) => setState(() => _availability = v),
            onSend: () {
              final offer = LendOffer(
                id: 'o_${DateTime.now().millisecondsSinceEpoch}',
                requestId: widget.requestId,
                lenderId: 'uid_durga',
                availability: _availability,
                note: _noteCtrl.text,
                status: OfferStatus.pending,
                createdAt: DateTime.now(),
                lenderDisplayName:
                    ref.read(currentUserProvider)?.displayName ?? 'Student',
                lenderSection:
                    ref.read(currentUserProvider)?.classSection ?? '',
                lenderTrustScore: 12,
              );
              ref
                  .read(sentOffersProvider.notifier)
                  .add(widget.requestId, offer);
              setState(() => _showOfferSheet = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Offer sent ✨ (simulated)'),
                  backgroundColor: AppColors.mint,
                ),
              );
            },
            onCancel: () => setState(() => _showOfferSheet = false),
          ),
      ],
    );
  }

  void _accept(BuildContext context, ItemRequest request, LendOffer offer) {
    final existing = ref.read(activeLoanProvider);
    if (existing != null &&
        existing.status != LoanStatus.completed &&
        existing.status != LoanStatus.cancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Finish your current demo loan before starting another.',
          ),
        ),
      );
      return;
    }
    final loan = Loan(
      id: 'loan_${DateTime.now().millisecondsSinceEpoch}',
      requestId: request.id,
      offerId: offer.id,
      requesterId: request.requesterId,
      lenderId: offer.lenderId,
      campusId: request.campusId,
      itemName: request.itemName,
      category: request.category,
      borrowDurationMinutes: request.borrowDurationMinutes,
      status: LoanStatus.awaitingHandoff,
      createdAt: DateTime.now(),
      lenderDisplayName: offer.lenderDisplayName,
      lenderSection: offer.lenderSection,
      borrowerDisplayName:
          ref.read(currentUserProvider)?.displayName ?? 'Student',
      borrowerSection: ref.read(currentUserProvider)?.classSection ?? '',
      exactHandoffPoint:
          ref.read(privateHandoffProvider)[request.id] ??
          'Library steps, 2nd pillar',
    );
    ref.read(activeLoanProvider.notifier).set(loan);
    ref.read(myRequestsProvider.notifier).remove(request.id);
    ref
        .read(notificationsProvider.notifier)
        .add(
          AppNotification(
            id: 'n_${DateTime.now().millisecondsSinceEpoch}',
            type: 'match',
            title: 'Matched with ${offer.lenderDisplayName}!',
            emoji: '🎉',
            createdAt: DateTime.now(),
          ),
        );
    context.go('/loan');
  }

  void _simulateAccepted(BuildContext context, ItemRequest request) {
    final existing = ref.read(activeLoanProvider);
    if (existing != null &&
        existing.status != LoanStatus.completed &&
        existing.status != LoanStatus.cancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Finish your current demo loan before starting another.',
          ),
        ),
      );
      return;
    }
    final loan = Loan(
      id: 'loan_${DateTime.now().millisecondsSinceEpoch}',
      requestId: request.id,
      offerId: 'o_sim',
      requesterId: request.requesterId,
      lenderId: 'uid_durga',
      campusId: request.campusId,
      itemName: request.itemName,
      category: request.category,
      borrowDurationMinutes: request.borrowDurationMinutes,
      status: LoanStatus.awaitingHandoff,
      createdAt: DateTime.now(),
      lenderDisplayName:
          ref.read(currentUserProvider)?.displayName ?? 'Student',
      lenderSection: ref.read(currentUserProvider)?.classSection ?? '',
      borrowerDisplayName: request.requesterDisplayName,
      borrowerSection: request.requesterSection,
      exactHandoffPoint:
          ref.read(privateHandoffProvider)[request.id] ??
          'Library steps, 2nd pillar',
    );
    ref.read(activeLoanProvider.notifier).set(loan);
    ref.read(campusRequestsProvider.notifier).remove(request.id);
    context.go('/loan');
  }
}

// ---------------------------------------------------------------------------
// Offer card (shown to requester)
// ---------------------------------------------------------------------------

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer, required this.onAccept});
  final LendOffer offer;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                offer.lenderDisplayName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lavender,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${offer.lenderTrustScore} loans',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '🕒 ${offer.availability}${offer.note.isNotEmpty ? ' · "${offer.note}"' : ''}',
            style: const TextStyle(fontSize: 13, color: AppColors.onLight),
          ),
          const SizedBox(height: 10),
          GotOneButton(
            label: 'Accept ${offer.lenderDisplayName} ✓',
            color: AppColors.mint,
            small: true,
            onPressed: onAccept,
          ),
        ],
      ),
    );
  }
}

class _EmptyOffers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('⏳', style: TextStyle(fontSize: 54)),
        SizedBox(height: 8),
        Text(
          'Waiting for offers…',
          style: TextStyle(fontSize: 14, color: AppColors.muted),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Offer sheet (lender sends offer)
// ---------------------------------------------------------------------------

class _OfferSheet extends StatelessWidget {
  const _OfferSheet({
    required this.availability,
    required this.noteCtrl,
    required this.onAvChange,
    required this.onSend,
    required this.onCancel,
  });
  final String availability;
  final TextEditingController noteCtrl;
  final ValueChanged<String> onAvChange;
  final VoidCallback onSend;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: Material(
      color: Colors.black54,
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Material(
              color: AppColors.card,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Be a hero 🦸',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'When can you lend?',
                      style: TextStyle(color: AppColors.onLight),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final opt in ['Now', 'In 30 min', 'After class'])
                          ChoiceChip(
                            label: Text(opt),
                            selected: availability == opt,
                            selectedColor: AppColors.onLight,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: availability == opt
                                  ? Colors.white
                                  : AppColors.onLight,
                            ),
                            onSelected: (_) => onAvChange(opt),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Note (optional)',
                      style: TextStyle(color: AppColors.onLight),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: noteCtrl,
                      style: const TextStyle(color: AppColors.onLight),
                      decoration: const InputDecoration(
                        hintText: "Hey, I'm near the canteen",
                      ),
                    ),
                    const SizedBox(height: 18),
                    GotOneButton(label: 'Send offer', onPressed: onSend),
                    const SizedBox(height: 10),
                    GotOneButton(
                      label: 'Cancel',
                      color: Colors.white,
                      onPressed: onCancel,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Post Request Bottom Sheet
// ---------------------------------------------------------------------------

class PostRequestSheet extends ConsumerStatefulWidget {
  const PostRequestSheet({super.key});

  @override
  ConsumerState<PostRequestSheet> createState() => _PostRequestSheetState();
}

class _PostRequestSheetState extends ConsumerState<PostRequestSheet> {
  final _itemCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _privCtrl = TextEditingController();
  ItemCategory? _cat;
  String? _zone;
  String? _by;
  String? _dur;

  static const _zones = ['Block A', 'Library', 'Canteen', 'Hostel Row'];

  int get _filledFields => [
    _itemCtrl.text.trim().isNotEmpty,
    _cat != null,
    _zone != null,
    _by != null,
    _dur != null,
  ].where((v) => v).length;

  void _submit() {
    if (_filledFields != 5 || _privCtrl.text.trim().isEmpty) return;
    final now = DateTime.now();
    final req = ItemRequest(
      id: 'r_${now.millisecondsSinceEpoch}',
      requesterId: 'uid_durga',
      campusId: 'bvrit',
      itemName: _itemCtrl.text.trim(),
      category: _cat!,
      description: _descCtrl.text.isEmpty ? 'No extra details' : _descCtrl.text,
      zone: _zone ?? _zones[0],
      neededBy: now.add(
        Duration(
          minutes: switch (_by) {
            'Now' => 5,
            '1 hr' => 60,
            'Today' => 360,
            _ => 1440,
          },
        ),
      ),
      borrowDurationMinutes: _durMins(_dur ?? '1 hr'),
      status: RequestStatus.open,
      createdAt: now,
      requesterDisplayName:
          ref.read(currentUserProvider)?.displayName ?? 'Student',
      requesterSection: ref.read(currentUserProvider)?.classSection ?? '',
    );
    ref.read(privateHandoffProvider.notifier).state = {
      ...ref.read(privateHandoffProvider),
      req.id: _privCtrl.text.trim(),
    };
    ref.read(myRequestsProvider.notifier).add(req);
    ref
        .read(notificationsProvider.notifier)
        .add(
          AppNotification(
            id: 'n_${now.millisecondsSinceEpoch}',
            type: 'request_posted',
            title: 'Your request for ${req.itemName} is live!',
            emoji: '🚀',
            createdAt: now,
          ),
        );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request is live! 🚀'),
        backgroundColor: AppColors.mint,
      ),
    );
    context.go('/app/activity');
  }

  int _durMins(String s) {
    if (s == '1 hr') return 60;
    if (s == '3 hrs') return 180;
    return 1440;
  }

  @override
  void dispose() {
    _itemCtrl.dispose();
    _descCtrl.dispose();
    _privCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = _filledFields / 5;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Ask for something ✍️',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onLight,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: AppColors.onLight),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Progress bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0x22000000),
                borderRadius: BorderRadius.circular(9),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: pct,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _sheetLabel('What do you need?'),
            TextField(
              controller: _itemCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: AppColors.onLight, fontSize: 14),
              decoration: const InputDecoration(hintText: 'e.g. HDMI cable'),
            ),
            _sheetLabel('Category'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ItemCategory.values
                  .map(
                    (c) => GestureDetector(
                      onTap: () => setState(() => _cat = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: _cat == c
                              ? const Color(0xFF111111)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          '${c.emoji} ${c.label}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _cat == c ? Colors.white : AppColors.onLight,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            _sheetLabel('Details'),
            TextField(
              controller: _descCtrl,
              maxLines: 2,
              style: const TextStyle(color: AppColors.onLight, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Anything that helps',
              ),
            ),
            _sheetLabel('Broad pickup zone'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _zones
                  .map(
                    (z) => GestureDetector(
                      onTap: () => setState(() => _zone = z),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: _zone == z
                              ? const Color(0xFF111111)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          z,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _zone == z
                                ? Colors.white
                                : AppColors.onLight,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            _sheetLabel('🔒 Exact handoff point (private)'),
            TextField(
              controller: _privCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: AppColors.onLight, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Shared only after a match',
              ),
            ),
            _sheetLabel('Needed by'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Now', '1 hr', 'Today', 'Tomorrow']
                  .map(
                    (b) => GestureDetector(
                      onTap: () => setState(() => _by = b),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: _by == b
                              ? const Color(0xFF111111)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          b,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _by == b ? Colors.white : AppColors.onLight,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            _sheetLabel('Borrow for'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['1 hr', '3 hrs', '1 day']
                  .map(
                    (d) => GestureDetector(
                      onTap: () => setState(() => _dur = d),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: _dur == d
                              ? const Color(0xFF111111)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          d,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _dur == d ? Colors.white : AppColors.onLight,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            GotOneButton(
              label: 'Post request 🚀',
              onPressed:
                  (_filledFields == 5 && _privCtrl.text.trim().isNotEmpty)
                  ? _submit
                  : null,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _sheetLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.onLight,
      ),
    ),
  );
}
