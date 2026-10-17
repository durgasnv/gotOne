import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets.dart';

/// Welcome / splash screen — entry point for unauthenticated users.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final List<AnimationController> _emojiCtrl;
  late final List<Animation<double>> _emojiAnim;

  static const _emojis = ['🎒', '🔌', '☂️', '🧮'];

  @override
  void initState() {
    super.initState();
    _emojiCtrl = List.generate(
      _emojis.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2400),
      )..repeat(reverse: true),
    );

    _emojiAnim = List.generate(
      _emojis.length,
      (i) => Tween<double>(begin: 0, end: -14).animate(
        CurvedAnimation(
          parent: _emojiCtrl[i],
          curve: Interval(i * 0.125, i * 0.125 + 0.5, curve: Curves.easeInOut),
        ),
      ),
    );

    // Start each emoji with a slight delay
    for (var i = 0; i < _emojis.length; i++) {
      Future.delayed(Duration(milliseconds: i * 300), () {
        if (mounted) _emojiCtrl[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _emojiCtrl) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 26),
                // Floating emoji row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_emojis.length, (i) {
                    return AnimatedBuilder(
                      animation: _emojiCtrl[i],
                      builder: (_, __) => Transform.translate(
                        offset: Offset(0, _emojiAnim[i].value),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            _emojis[i],
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                // Logo
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -2,
                      color: AppColors.onDark,
                    ),
                    children: [
                      TextSpan(text: 'got'),
                      TextSpan(
                        text: 'One',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Need it? Someone's gotOne.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onDark,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Borrow and lend everyday stuff with verified students on your campus. No money, no delivery — just good vibes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.muted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 26),
                // Feature bullets
                ..._bullets(),
                const SizedBox(height: 32),
                GotOneButton(
                  label: "Let's go →",
                  onPressed: () => context.push('/auth/email'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Design prototype — all data and actions are simulated, no real backend.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _bullets() {
    final items = [
      ('🔒', 'College email · demo sign-in'),
      ('📍', 'Campus-local — no strangers'),
      ('🤝', 'Private handoff details after match'),
    ];
    return items.map((t) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Text(t.$1, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                t.$2,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onDark,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
