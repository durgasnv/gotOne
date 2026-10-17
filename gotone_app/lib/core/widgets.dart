import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'models/models.dart';

// ---------------------------------------------------------------------------
// GotOneButton — primary coral CTA
// ---------------------------------------------------------------------------

class GotOneButton extends StatelessWidget {
  const GotOneButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.small = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool small;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.accent;
    final fg = ThemeData.estimateBrightnessForColor(bg) == Brightness.light
        ? AppColors.onLight
        : AppColors.onDark;

    final style = ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      minimumSize: small ? const Size(0, 38) : const Size.fromHeight(50),
      padding: small
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 0)
          : const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      textStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: small ? 13 : 15,
      ),
      shape: const StadiumBorder(),
      elevation: 0,
    );

    if (icon != null) {
      return ElevatedButton.icon(
        style: style,
        onPressed: onPressed,
        icon: Icon(icon, size: small ? 14 : 18),
        label: Text(label),
      );
    }

    return ElevatedButton(
      style: style,
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

// ---------------------------------------------------------------------------
// CategoryChip
// ---------------------------------------------------------------------------

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.mint : AppColors.surface,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          '$emoji $label',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.onLight : const Color(0xFFDDDDDD),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// StatusBadge
// ---------------------------------------------------------------------------

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, this.urgent = false});

  final String label;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: urgent ? AppColors.yellow : Colors.white,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        urgent ? '⚡ Urgent' : label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.onLight,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ItemTag — small pill tag (zone, duration, time)
// ---------------------------------------------------------------------------

class ItemTag extends StatelessWidget {
  const ItemTag(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6, top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.53),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.onLight,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CategoryIcon — round icon badge
// ---------------------------------------------------------------------------

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.category, this.size = 48});

  final ItemCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _bg(category),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Text(category.emoji, style: TextStyle(fontSize: size * 0.5)),
      ),
    );
  }

  static Color _bg(ItemCategory c) {
    switch (c) {
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
}

// ---------------------------------------------------------------------------
// SkeletonLoader — loading shimmer placeholder
// ---------------------------------------------------------------------------

class SkeletonCard extends StatefulWidget {
  const SkeletonCard({super.key, this.height = 130});
  final double height;

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (ctx, _) => Container(
        height: widget.height,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value, 0),
            colors: const [
              Color(0xFF222222),
              Color(0xFF2E2E33),
              Color(0xFF222222),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ConfettiOverlay — celebration burst
// ---------------------------------------------------------------------------

class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key, required this.child});
  final Widget child;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final _items = <_ConfettiItem>[];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    for (var i = 0; i < 22; i++) {
      _items.add(_ConfettiItem());
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => IgnorePointer(
            child: Stack(
              children: _items
                  .map((item) => _buildParticle(item, _ctrl.value))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticle(_ConfettiItem item, double t) {
    final opacity = (1 - t).clamp(0.0, 1.0);
    final x = item.startX + item.dx * t;
    final y = item.startY + item.dy * t;
    return Positioned(
      left: x,
      top: y,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: item.rotation * t,
          child: Text(item.emoji, style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}

class _ConfettiItem {
  static final _emojis = ['🎉', '✨', '🧡', '💜', '🟢'];
  static var _i = 0;

  final String emoji;
  final double startX;
  final double startY;
  final double dx;
  final double dy;
  final double rotation;

  _ConfettiItem()
    : emoji = _emojis[_i++ % _emojis.length],
      startX = 150 + ((_i * 37) % 100 - 50).toDouble(),
      startY = 300,
      dx = ((_i * 73) % 340 - 170).toDouble(),
      dy = -((_i * 53) % 300 + 60).toDouble(),
      rotation = (_i * 1.1) % 6.28;
}

// ---------------------------------------------------------------------------
// SectionHeader
// ---------------------------------------------------------------------------

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// GotOneBottomNav
// ---------------------------------------------------------------------------

class GotOneBottomNav extends StatelessWidget {
  const GotOneBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onPost,
    this.notifBadge = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onPost;
  final int notifBadge;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBtn(
                icon: Icons.home_rounded,
                label: 'Home',
                active: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavBtn(
                icon: Icons.list_alt_rounded,
                label: 'Activity',
                active: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              // Centre FAB
              GestureDetector(
                onTap: onPost,
                child: Container(
                  width: 74,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Center(
                    child: Text(
                      '+',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onLight,
                      ),
                    ),
                  ),
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _NavBtn(
                    icon: Icons.notifications_rounded,
                    label: 'Alerts',
                    active: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                  if (notifBadge > 0)
                    Positioned(
                      top: 2,
                      right: 8,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              _NavBtn(
                icon: Icons.person_rounded,
                label: 'Profile',
                active: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: active
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: active ? AppColors.onLight : AppColors.muted,
            ),
            if (active) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onLight,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
