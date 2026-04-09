import 'package:chottu_link/chottu_link.dart';

import 'package:deeplinking/first_screen.dart';
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
      ],
    );

    ChottuLink.onLinkReceived.listen((String link) {
      debugPrint(" ✅ Link Received: $link");

      final uri = Uri.tryParse(link);
      if (uri != null) {
        final path = '/second';
        debugPrint(" 📍 Navigating to path: $path");

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            if (path == '/second') {
              _router.push('/second');
            } else if (path == '/third') {
              _router.push('/third');
            } else {
              _router.go('/');
            }
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
