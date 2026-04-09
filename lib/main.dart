import 'package:chottu_link/chottu_link.dart';

import 'package:deeplinking/first_screen.dart';
import 'package:deeplinking/link_sharing_screen.dart';
import 'package:deeplinking/second_screen.dart';
import 'package:deeplinking/third_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ChottuLink.init(apiKey: 'c_app_uFWIcj8pXff28y83rSGCbBHCGKIsC7Ev');

  // Try to get the cold start link from the stream within a short timeout.
  // If the app was opened via a deep link, the first stream event arrives
  // almost immediately. If no link arrives, we treat it as a normal launch.
  String? coldStartPath;
  try {
    final firstLink = await ChottuLink.onLinkReceived
        .first
        .timeout(const Duration(milliseconds: 300));

    final uri = Uri.tryParse('https://heystyle.chottu.link/first');
    if (uri != null && uri.path.isNotEmpty && uri.path != '/') {
      coldStartPath = uri.path;
      debugPrint("🚀 Cold start deep link captured: $coldStartPath");
    }
  } catch (_) {
    // Timeout = normal launch, no deep link
    debugPrint("ℹ️ No cold start deep link");
  }

  runApp(MyApp(coldStartPath: coldStartPath));
}

class MyApp extends StatefulWidget {
  final String? coldStartPath;
  const MyApp({super.key, this.coldStartPath});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  static const _nestedRoutes = {'/second', '/third', '/link-sharing'};

  @override
  void initState() {
    super.initState();

    _router = GoRouter(
      // Cold start: go directly to deep link screen — zero flash
      initialLocation: widget.coldStartPath ?? '/first',

      routes: [
        GoRoute(
          path: '/first',
          builder: (context, state) => const FirstScreen(),
        ),
        GoRoute(
          path: '/second',
          builder: (context, state) => const SecondScreen(),
        ),
        GoRoute(
          path: '/third',
          builder: (context, state) => const ThirdScreen(),
        ),
        GoRoute(
          path: '/link-sharing',
          builder: (context, state) => const LinkSharingScreen(),
        ),
      ],
    );

    // This listener now only handles WARM START / foreground links
    // because the cold start link was already consumed above in main()
    ChottuLink.onLinkReceived.listen((String link) {
      debugPrint("✅ Warm link received: $link");

      final uri = Uri.tryParse(link);
      if (uri == null) return;

      final String path = uri.path.isEmpty ? '/' : uri.path;
      debugPrint("📍 Navigate to: $path");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        if (_nestedRoutes.contains(path)) {
          // Push target on top of /first so back button works
          // _router.go('/first');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _router.push('/first/third');
          });
        } else {
          _router.go(path);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: _router,
    );
  }
}