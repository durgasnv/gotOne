import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/models/models.dart';
import '../../core/models/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets.dart';
import '../../core/helpers.dart';

// ---------------------------------------------------------------------------
// Request Card — used in Feed and Activity tabs
// ---------------------------------------------------------------------------

class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.request,
    this.mine = false,
    this.offerCount = 0,
    this.onTap,
  });

  final ItemRequest request;
  final bool mine;
  final int offerCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = _cardBg(request.category, request.isUrgent);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                CategoryIcon(category: request.category),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.itemName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onLight,
                        ),
                      ),
                      Text(
                        mine ? 'Your request' : request.requesterDisplayName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0x99000000),
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: mine
                      ? '$offerCount ${offerCount == 1 ? 'offer' : 'offers'}'
                      : request.status.name,
                  urgent: request.isUrgent,
                ),
              ],
            ),
            // Description
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                request.description,
                style: const TextStyle(fontSize: 14, color: AppColors.onLight),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Tags row
            Wrap(
              children: [
                ItemTag('📍 ${request.zone}'),
                ItemTag('⏳ ${_durLabel(request.borrowDurationMinutes)}'),
                ItemTag('🕒 by ${_timeLabel(request.neededBy)}'),
              ],
            ),
            const SizedBox(height: 12),
            // CTA button
            GotOneButton(
              label: mine ? 'See offers 👀' : "I've got this! ✋",
              small: true,
              color: const Color(0xFF111111),
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }

  static Color _cardBg(ItemCategory cat, bool urgent) {
    if (urgent) return const Color(0xFFFFB199);
    switch (cat) {
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

  static String _durLabel(int mins) {
    if (mins < 60) return '$mins min';
    if (mins < 1440) return '${mins ~/ 60} hr${mins ~/ 60 > 1 ? 's' : ''}';
    return '${mins ~/ 1440} day${mins ~/ 1440 > 1 ? 's' : ''}';
  }

  static String _timeLabel(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.inMinutes < 5) return 'Now';
    if (diff.inHours < 1) return 'in ${diff.inMinutes} min';
    if (diff.inHours < 24) return DateFormat('h:mm a').format(dt);
    return 'Today';
  }
}

// ---------------------------------------------------------------------------
// Home Screen
// ---------------------------------------------------------------------------

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ItemCategory? _cat;
  String _query = '';
  bool _loading = true;
  bool _swipeMode = true;

  static const _zones = [
    'All campus',
    'Block A',
    'Block C',
    'Library',
    'Canteen',
    'Hostel Row',
  ];
  int _zoneIdx = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  List<ItemRequest> get _filtered {
    final requests = ref.watch(campusRequestsProvider);
    return requests.where((r) {
      final matchCat = _cat == null || r.category == _cat;
      final matchQ =
          _query.isEmpty ||
          r.itemName.toLowerCase().contains(_query.toLowerCase()) ||
          r.description.toLowerCase().contains(_query.toLowerCase());
      return matchCat &&
          matchQ &&
          (_zoneIdx == 0 || r.zone == _zones[_zoneIdx]) &&
          r.status == RequestStatus.open;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final reqs = ref.watch(campusRequestsProvider);
    final activeLoan = ref.watch(activeLoanProvider);
    final urgentCount = reqs.where((r) => r.isUrgent).length;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Campus feed',
                      style: TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(
                          () => _zoneIdx = (_zoneIdx + 1) % _zones.length,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          '📍 ${_zones[_zoneIdx]} ▾',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onLight,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Headline
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w300,
                      color: AppColors.onDark,
                      letterSpacing: -1.5,
                    ),
                    children: [
                      TextSpan(
                        text:
                            'Hey 👋 ${ref.watch(currentUserProvider)?.displayName ?? 'Student'}, ',
                      ),
                      TextSpan(
                        text: '${reqs.length} people',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const TextSpan(text: ' need something near you'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Stat pills
                Row(
                  children: [
                    _statPill('⚡ $urgentCount urgent', AppColors.yellow),
                    const SizedBox(width: 8),
                    _statPill('🤝 12 lent', AppColors.sky),
                  ],
                ),
                const SizedBox(height: 12),
                // Search field (only in feed mode)
                if (!_swipeMode)
                  TextField(
                    onChanged: (v) => setState(() => _query = v),
                    style: const TextStyle(
                      color: AppColors.onLight,
                      fontSize: 14,
                    ),
                    decoration: const InputDecoration(
                      hintText: '🔍 What does someone need?',
                    ),
                  ),
                const SizedBox(height: 12),
                // Category chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      CategoryChip(
                        label: 'All',
                        emoji: '✨',
                        selected: _cat == null,
                        onTap: () => setState(() => _cat = null),
                      ),
                      const SizedBox(width: 8),
                      ...ItemCategory.values.map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CategoryChip(
                            label: c.label,
                            emoji: c.emoji,
                            selected: _cat == c,
                            onTap: () => setState(() => _cat = c),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Banner
                _Banner(),
                const SizedBox(height: 8),
                // Active loan chip
                if (activeLoan != null &&
                    activeLoan.status != LoanStatus.completed)
                  GestureDetector(
                    onTap: () => context.push('/loan'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${activeLoan.category.emoji} Active loan with ${activeLoan.lenderId == 'uid_durga' ? activeLoan.borrowerDisplayName : activeLoan.lenderDisplayName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.onLight,
                            ),
                          ),
                          const Text(
                            'Tap to track →',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                // Feed / Swipe toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Live on campus',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: AppColors.onDark,
                        ),
                      ),
                    ),
                    _SegmentedControl(
                      options: const ['Feed', 'Swipe'],
                      selected: _swipeMode ? 1 : 0,
                      onSelect: (i) => setState(() => _swipeMode = i == 1),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),

        // Feed or Swipe
        if (_swipeMode)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _loading
                  ? const SkeletonCard(height: 400)
                  : _SwipeDeck(requests: _filtered),
            ),
          )
        else ...[
          if (_loading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [SkeletonCard(), SkeletonCard(), SkeletonCard()],
                ),
              ),
            )
          else if (_filtered.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    Text('🫥', style: TextStyle(fontSize: 54)),
                    SizedBox(height: 12),
                    Text(
                      'Nothing yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onDark,
                      ),
                    ),
                    Text(
                      "Be the first to ask — someone's probably got one.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((_, i) {
                  final r = _filtered[i];
                  return RequestCard(
                    request: r,
                    onTap: () => context.push('/request/${r.id}'),
                  );
                }, childCount: _filtered.length),
              ),
            ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _statPill(String text, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.onLight,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Banner widget (hero CTA at top of feed)
// ---------------------------------------------------------------------------

class _Banner extends StatefulWidget {
  @override
  State<_Banner> createState() => _BannerState();
}

class _BannerState extends State<_Banner> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rot;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _rot = Tween<double>(begin: 0, end: 0.244).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.yellow,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Be someone\'s hero today 🦸',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.onLight,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Got a spare charger? 3 people nearby need one.',
                style: TextStyle(fontSize: 12, color: AppColors.onLight),
              ),
            ],
          ),
          Positioned(
            right: -6,
            bottom: -14,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Transform.rotate(
                angle: _rot.value,
                child: const Text('🔌', style: TextStyle(fontSize: 64)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Segmented Control
// ---------------------------------------------------------------------------

class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (i) {
          final active = selected == i;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
    );
  }
}

// ---------------------------------------------------------------------------
// Swipe Deck
// ---------------------------------------------------------------------------

class _SwipeDeck extends ConsumerStatefulWidget {
  const _SwipeDeck({required this.requests});
  final List<ItemRequest> requests;

  @override
  ConsumerState<_SwipeDeck> createState() => _SwipeDeckState();
}

class _SwipeDeckState extends ConsumerState<_SwipeDeck> {
  final _skipped = <String>{};

  @override
  Widget build(BuildContext context) {
    final offers = ref.watch(sentOffersProvider);
    final deck = widget.requests
        .where((r) => !_skipped.contains(r.id) && !offers.containsKey(r.id))
        .toList();
    if (deck.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 30),
          const Text('🎉', style: TextStyle(fontSize: 54)),
          const Text(
            "You're all caught up",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          GotOneButton(
            label: 'Reshuffle skipped',
            small: true,
            onPressed: () => setState(() => _skipped.clear()),
          ),
        ],
      );
    }
    final visible = deck.take(3).toList().reversed.toList();
    void offer(ItemRequest request) => context.push('/request/${request.id}');
    return Column(
      children: [
        SizedBox(
          height: 440,
          child: Stack(
            children: [
              for (var i = 0; i < visible.length; i++)
                _SwipeCard(
                  key: ValueKey(visible[i].id),
                  request: visible[i],
                  stackOffset: (visible.length - 1 - i).toDouble(),
                  isTop: i == visible.length - 1,
                  onSkip: () => setState(() => _skipped.add(visible[i].id)),
                  onOffer: () => offer(visible[i]),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RoundBtn(
              icon: '✕',
              color: AppColors.surface,
              onTap: () => setState(() => _skipped.add(deck.first.id)),
            ),
            const SizedBox(width: 24),
            _RoundBtn(
              icon: '✋',
              color: AppColors.mint,
              onTap: () => offer(deck.first),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Swipe left to skip · right to help',
          style: TextStyle(fontSize: 12, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _SwipeCard extends StatefulWidget {
  const _SwipeCard({
    super.key,
    required this.request,
    required this.stackOffset,
    required this.isTop,
    required this.onSkip,
    required this.onOffer,
  });

  final ItemRequest request;
  final double stackOffset;
  final bool isTop;
  final VoidCallback onSkip;
  final VoidCallback onOffer;

  @override
  State<_SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<_SwipeCard>
    with SingleTickerProviderStateMixin {
  double _dx = 0;
  bool _dragging = false;

  Color get _bg {
    if (widget.request.isUrgent) return const Color(0xFFFFB199);
    switch (widget.request.category) {
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
    final offset = widget.stackOffset;
    final ty = offset * 14;
    final scale = 1 - offset * 0.05;

    return Positioned.fill(
      child: GestureDetector(
        onHorizontalDragUpdate: widget.isTop
            ? (d) => setState(() {
                _dx += d.delta.dx;
                _dragging = true;
              })
            : null,
        onHorizontalDragEnd: widget.isTop
            ? (d) {
                if (_dx > 90) {
                  setState(() {
                    _dx = 0;
                    _dragging = false;
                  });
                  widget.onOffer();
                } else if (_dx < -90) {
                  widget.onSkip();
                } else {
                  setState(() {
                    _dx = 0;
                    _dragging = false;
                  });
                }
              }
            : null,
        child: AnimatedContainer(
          duration: _dragging
              ? Duration.zero
              : const Duration(milliseconds: 350),
          curve: Curves.elasticOut,
          transform: Matrix4.identity()
            ..translateByDouble(_dx, ty, 0, 1)
            ..scaleByDouble(scale, scale, 1, 1),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // SKIP label
              Positioned(
                top: 20,
                left: 18,
                child: Opacity(
                  opacity: (_dx < 0 ? (-_dx / 90).clamp(0.0, 1.0) : 0.0),
                  child: Transform.rotate(
                    angle: -0.21,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFDD3333),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'SKIP',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: Color(0xFFDD3333),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // I'VE GOT THIS label
              Positioned(
                top: 20,
                right: 18,
                child: Opacity(
                  opacity: (_dx > 0 ? (_dx / 90).clamp(0.0, 1.0) : 0.0),
                  child: Transform.rotate(
                    angle: 0.21,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF0A7A3D),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "I'VE GOT THIS ✋",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Color(0xFF0A7A3D),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Card content
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.request.category.emoji,
                      style: const TextStyle(fontSize: 84),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.request.itemName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                        color: AppColors.onLight,
                      ),
                    ),
                    Text(
                      widget.request.requesterDisplayName,
                      style: const TextStyle(
                        color: Color(0x99000000),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.request.description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.onLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      children: [
                        ItemTag('📍 ${widget.request.zone}'),
                        ItemTag(
                          '⏳ ${durLabel(widget.request.borrowDurationMinutes)}',
                        ),
                        ItemTag('🕒 by ${timeLabel(widget.request.neededBy)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 26))),
      ),
    );
  }
}
