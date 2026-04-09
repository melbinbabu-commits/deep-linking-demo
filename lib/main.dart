import 'dart:async';

import 'package:chottu_link/chottu_link.dart';
import 'package:chottu_link/wrapper/chottu_link_platform_interface.dart';

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
  StreamSubscription<String>? _linkSubscription;
  bool _isBootstrappingInitialLink = true;
  String? _initialHandledPath;

  @override
  void initState() {
    super.initState();

    _router = GoRouter(
      initialLocation: '/first',
errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('NOT FOUND')),
      ),
      routes: [
        GoRoute(
          path: '/first',
          builder: (context, state) => const FirstScreen(),
          routes: [
            GoRoute(
              path: 'second',
              builder: (context, state) => const SecondScreen(),
            ),
            GoRoute(
              path: 'third',
              builder: (context, state) => const ThirdScreen(),
            ),
            GoRoute(
              path: 'link-sharing',
              builder: (context, state) => const LinkSharingScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/',
          redirect: (context, state) => '/first',
        ),
      ],
    );

    _linkSubscription = ChottuLink.onLinkReceived.listen(_handleIncomingLink);
    unawaited(_bootstrapInitialLink());
  }

  Future<void> _bootstrapInitialLink() async {
    try {
      await ChottuLinkPlatform.instance.getAppLinkData();
    } catch (error, stackTrace) {
      debugPrint('❌ Failed to bootstrap initial link: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isBootstrappingInitialLink = false;
      _initialHandledPath = null;
    }
  }

  void _handleIncomingLink(String link) {
    final uri = Uri.tryParse(link);
    if (uri == null) return;

    final String path = _mapIncomingPathToAppLocation(uri.path);
    debugPrint("📍 Navigate to: $path");

    if (_isBootstrappingInitialLink) {
      if (_initialHandledPath == path) {
        return;
      }
      _initialHandledPath ??= path;
    }

    if (!mounted) return;
    _router.go(path);
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _router.dispose();
    super.dispose();
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

String _mapIncomingPathToAppLocation(String rawPath) {
  final normalizedPath = rawPath.isEmpty ? '/' : rawPath;

  switch (normalizedPath) {
    case '/':
    case '/first':
      return '/first';
    case '/second':
      return '/first/second';
    case '/third':
      return '/first/third';
    case '/link-sharing':
      return '/first/link-sharing';
    default:
      return normalizedPath;
  }
}
