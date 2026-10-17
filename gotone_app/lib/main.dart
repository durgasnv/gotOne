import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Force dark status bar icons to be light (white) for the dark theme.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  // Lock to portrait.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) => runApp(const ProviderScope(child: GotOneApp())));
}

class GotOneApp extends StatelessWidget {
  const GotOneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'gotOne',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      builder: (context, child) => ColoredBox(
        color: const Color(0xFF0B0B0D),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ClipRect(child: child ?? const SizedBox.shrink()),
          ),
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
