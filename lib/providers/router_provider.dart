import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_docs/providers/auth_provider.dart';
import 'package:google_docs/screens/document_screen.dart';
import 'package:google_docs/screens/home_screen.dart';
import 'package:google_docs/screens/login_screen.dart' show LoginScreen;
import 'package:google_docs/screens/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final initState = ref.watch(initUserProvider);
  final user = ref.watch(userProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/document/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return DocumentScreen(id!);
        },
      ),
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    ],
    redirect: (context, state) {
      if (initState.isLoading) {
        if (state.matchedLocation != '/splash') {
          return '/splash';
        }
        return null;
      }

      if (user == null) {
        if (state.matchedLocation != '/login') {
          return '/login';
        }
        return null;
      }

      // Allow /home and /document/:id for logged-in users
      if (state.matchedLocation == '/splash' ||
          state.matchedLocation == '/login') {
        return '/home';
      }

      // No redirect needed for /home or /document/:id
      return null;
    },
  );
});
