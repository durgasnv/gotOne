import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets.dart';
import '../../core/models/models.dart';
import '../../core/models/providers.dart';

/// Email verification screen — step 1/3 of onboarding.
class EmailScreen extends ConsumerStatefulWidget {
  const EmailScreen({super.key});

  @override
  ConsumerState<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends ConsumerState<EmailScreen> {
  final _ctrl = TextEditingController(text: 'you@bvrithyderabad.edu.in');
  bool _loading = false;
  String? _error;

  static final _collegePattern = RegExp(
    r'^[A-Z0-9._%+-]+@bvrithyderabad\.edu\.in$',
    caseSensitive: false,
  );

  void _submit() async {
    final email = _ctrl.text.trim();
    if (!_collegePattern.hasMatch(email)) {
      setState(() => _error = 'Use your @bvrithyderabad.edu.in email 🎓');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    // Simulate network call
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    ref.read(demoEmailProvider.notifier).state = email;
    setState(() => _loading = false);
    context.push('/auth/profile');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Progress bar
              const _ProgressBar(step: 1),
              const SizedBox(height: 32),
              const Text(
                "Prove you're\na student 🎓",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.5,
                  color: AppColors.onDark,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Demo sign-in for BVRIT Hyderabad. No email is sent.",
                style: TextStyle(fontSize: 15, color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _ctrl,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                style: const TextStyle(color: AppColors.onLight, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'you@college.edu.in',
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 20),
              _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    )
                  : GotOneButton(label: 'Continue in demo', onPressed: _submit),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile screen — step 2/3
// ---------------------------------------------------------------------------

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _name = TextEditingController(text: 'Durga');
  final _roll = TextEditingController(text: '24WH1A05XX');
  final _section = TextEditingController(text: 'CSE-B');

  String? _error;

  void _enter() {
    if ([_name.text, _roll.text, _section.text].any((v) => v.trim().isEmpty)) {
      setState(
        () => _error = 'Enter your name, roll number, and class / section.',
      );
      return;
    }
    final now = DateTime.now();
    ref.read(currentUserProvider.notifier).state = AppUser(
      uid: 'uid_durga',
      email: ref.read(demoEmailProvider),
      displayName: _name.text.trim(),
      campusId: 'bvrit',
      verifiedAt: now,
      createdAt: now,
      rollNumber: _roll.text.trim(),
      classSection: _section.text.trim(),
      lentCount: 12,
      borrowedCount: 5,
    );
    context.go('/app');
  }

  @override
  void dispose() {
    _name.dispose();
    _roll.dispose();
    _section.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const _ProgressBar(step: 2),
              const SizedBox(height: 32),
              const Text(
                'Demo campus profile 🎓\nWho are you?',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.5,
                  color: AppColors.onDark,
                ),
              ),
              const SizedBox(height: 24),
              _label('Name'),
              _field(_name, 'Durga'),
              _label('Roll number'),
              const Text(
                '(never shown publicly)',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 6),
              _field(_roll, '24WH1A05XX'),
              _label('Class / section'),
              _field(_section, 'CSE-B'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '🔒 Your roll number and class/section are only shared with your matched lending partner — never in the public feed.',
                  style: TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.accent),
                  ),
                ),
              GotOneButton(label: 'Enter campus 🏫', onPressed: _enter),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.onDark,
      ),
    ),
  );

  Widget _field(TextEditingController ctrl, String hint) => TextField(
    controller: ctrl,
    style: const TextStyle(color: AppColors.onLight, fontSize: 15),
    decoration: InputDecoration(hintText: hint),
  );
}

// ---------------------------------------------------------------------------
// Shared progress bar widget
// ---------------------------------------------------------------------------

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.step});
  final int step; // 1 or 2 out of 3

  @override
  Widget build(BuildContext context) {
    final pct = step / 3;
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(9),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: pct,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(9),
          ),
        ),
      ),
    );
  }
}
