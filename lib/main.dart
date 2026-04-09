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

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const FirstScreen()),
        GoRoute(
          path: '/second',
          builder: (context, state) => const SecondScreen(),
        ),
        GoRoute(
          path: '/third',
          builder: (context, state) => const ThirdScreen(),
        ),
        GoRoute(path: '/link-sharing', builder: (context, state) => const LinkSharingScreen())
      ],
    );

    ChottuLink.onLinkReceived.listen((String link) {
      debugPrint(" ✅ Link Received: $link");

      final uri = Uri.tryParse(link);
      if (uri != null) {
        // Extract path from URI, handling both scheme-based and path-only links
        String path = uri.path.isEmpty ? '/' : uri.path;
        
        // If path is empty but we have a scheme, use default path
        if (path == '/' && uri.scheme.isNotEmpty) {
          path = '/';
        }
        
        debugPrint(" 📍 Navigating to path: $path");
        debugPrint(" 📍 Full URI: $link");

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _router.push(path);
          }
        });
      }
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
