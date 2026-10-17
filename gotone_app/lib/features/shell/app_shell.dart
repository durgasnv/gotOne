import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets.dart';
import '../activity/activity_screens.dart';
import '../home/home_screen.dart';
import '../requests/request_screens.dart';

/// The main app shell — hosts the four-tab bottom nav and the FAB post button.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const _routes = [
    '/app',
    '/app/activity',
    '/app/notifications',
    '/app/profile',
  ];

  void _onTab(int i) {
    context.go(_routes[i]);
  }

  void _openPost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PostRequestSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifCount = ref
        .watch(notificationsProvider)
        .where((n) => n.isUnread)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: widget.child),
      bottomNavigationBar: GotOneBottomNav(
        currentIndex: _routes
            .indexOf(GoRouterState.of(context).uri.path)
            .clamp(0, 3),
        onTap: _onTab,
        onPost: _openPost,
        notifBadge: notifCount,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stub screens for sub-routes (actual content is in the scrollable sliver pages)
// ---------------------------------------------------------------------------

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) => const HomeScreen();
}

class ActivityTab extends StatelessWidget {
  const ActivityTab({super.key});

  @override
  Widget build(BuildContext context) => const ActivityScreen();
}

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  @override
  Widget build(BuildContext context) => const NotificationsScreen();
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) => const ProfileScreen();
}
