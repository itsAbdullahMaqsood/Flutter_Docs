import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_docs/providers/router_provider.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await GoogleSignInPlatform.instance.init(
    InitParameters(
      clientId: dotenv.env['CLIENT_ID'],
      serverClientId: dotenv.env['SERVER_CLIENT_ID'],
    ),
  );

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerStatefulWidget { 
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final GoRouter router = ref.watch(routerProvider);
    return MaterialApp.router(
      localizationsDelegates: const [FlutterQuillLocalizations.delegate],
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: router,
    );
  }
}
