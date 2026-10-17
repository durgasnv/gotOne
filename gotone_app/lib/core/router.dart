import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/welcome_screen.dart';
import '../features/auth/auth_screens.dart' as auth;
import '../features/shell/app_shell.dart';
import '../features/loans/loan_screen.dart';
import '../features/requests/request_screens.dart';

/// Application router using go_router with shell route for the tab scaffold.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Onboarding
    GoRoute(
      path: '/',
      pageBuilder: (_, state) => _slide(state, const WelcomeScreen()),
    ),
    GoRoute(
      path: '/auth/email',
      pageBuilder: (_, state) => _slide(state, const auth.EmailScreen()),
    ),
    GoRoute(
      path: '/auth/profile',
      pageBuilder: (_, state) => _slide(state, const auth.ProfileScreen()),
    ),

    // Main app — tab shell
    ShellRoute(
      builder: (_, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/app',
          pageBuilder: (_, state) => _fade(state, const HomeTab()),
        ),
        GoRoute(
          path: '/app/activity',
          pageBuilder: (_, state) => _fade(state, const ActivityTab()),
        ),
        GoRoute(
          path: '/app/notifications',
          pageBuilder: (_, state) => _fade(state, const NotificationsTab()),
        ),
        GoRoute(
          path: '/app/profile',
          pageBuilder: (_, state) => _fade(state, const ProfileTab()),
        ),
      ],
    ),

    // Full-screen routes (outside tab shell)
    GoRoute(
      path: '/request/:id',
      pageBuilder: (_, state) => _slide(
        state,
        RequestDetailScreen(requestId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/loan',
      pageBuilder: (_, state) => _slide(state, const LoanScreen()),
    ),
  ],
  errorBuilder: (_, state) => Scaffold(
    backgroundColor: const Color(0xFF111111),
    body: Center(
      child: Text(
        'Page not found: ${state.uri}',
        style: const TextStyle(color: Colors.white),
      ),
    ),
  ),
);

// Helpers
Page<void> _slide(GoRouterState state, Widget page) => CustomTransitionPage(
  key: state.pageKey,
  child: page,
  transitionsBuilder: (_, anim, __, child) => SlideTransition(
    position: Tween(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
    child: FadeTransition(opacity: anim, child: child),
  ),
);

Page<void> _fade(GoRouterState state, Widget page) => CustomTransitionPage(
  key: state.pageKey,
  child: page,
  transitionsBuilder: (_, anim, __, child) =>
      FadeTransition(opacity: anim, child: child),
);
