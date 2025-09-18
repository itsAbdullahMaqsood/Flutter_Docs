import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_docs/models/user_model.dart';
import 'package:google_docs/providers/auth_provider.dart';
import 'package:google_docs/repository/local_storage_repository.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as client;

class AndroidButtonGoogleSignIn extends ConsumerStatefulWidget {
  const AndroidButtonGoogleSignIn({super.key});

  @override
  ConsumerState<AndroidButtonGoogleSignIn> createState() =>
      _AndroidButtonGoogleSignInState();
}

class _AndroidButtonGoogleSignInState
    extends ConsumerState<AndroidButtonGoogleSignIn> {
  StreamSubscription<GoogleSignInAuthenticationEvent>? _sub;

  @override
  void initState() {
    super.initState();

    // Initialize Google Sign-In
    // unawaited(_init());
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only run once
    if (_sub == null) {
      unawaited(_init());
    }
  }

  // void getUserData() async {
  //   final navigator = Navigator.of(context);
  //   Client client = Client();
  //   Response? res;
  //   // This is where you would handle the sign-in logic, such as sending the
  //   // authentication tokens to your backend server.
  //   final sMessenger = ScaffoldMessenger.of(context);
  //   try {
  //     // final user = ref.read(googleAuthProvider);

  //     String? token = await localStorageRepo.getToken();

  //     if (token != null) {
  //       res = await client.post(
  //         Uri.parse('$host/'),
  //         headers: {
  //           'Content-Type': 'application/json; charset=UTF-8',
  //           'x-auth-code': token,
  //         },
  //       );
  //       switch (res.statusCode) {
  //         case 200:
  //           final newUser = UserModel.fromJson(
  //             jsonDecode(res.body)['user'],
  //           ).copyWith(token: token);
  //           localStorageRepo.setToken(newUser.token);
  //           ref.read(userProvider.notifier).update((state) => newUser);
  //           navigator.push(
  //             MaterialPageRoute(builder: (context) => HomeScreen()),
  //           );
  //           break;
  //         default:
  //           throw "Some error occured!";
  //       }

  //       //     navigator.push(
  //       //       MaterialPageRoute(builder: (context) => HomeScreen()),
  //       //     );
  //       //     break;
  //       //   default:
  //       //     throw "Some error occured!";
  //     }
  //   } catch (err) {
  //     print("$err");
  //     sMessenger.showSnackBar(SnackBar(content: Text('$err')));
  //   }
  // }

  Future<void> _init() async {
    final signInService = ref.read(googleSignInProvider);
    final router = GoRouter.of(context);
    final sMessenger = ScaffoldMessenger.of(context);
    final localStorageRepo = LocalStorageRepository();
    try {
      await signInService.initialize(
        clientId: dotenv.env['CLIENT_ID'],
        serverClientId: dotenv.env['SERVER_CLIENT_ID'],
      );

      _sub = signInService.authenticationEvents.listen(
        (event) async {
          if (event is GoogleSignInAuthenticationEventSignIn) {
            final user = event.user;
            // final auth = await user.authentication; // idToken & accessToken
            ref.read(googleAuthProvider.notifier).state = user;
            await fetchAndSetUserData(ref);
            final userAcc = UserModel(
              email: user.email,
              name: user.displayName!,
              profilePic: user.photoUrl!,
              token: '',
              uid: '',
            );
            var res = await client.post(
              Uri.parse('${dotenv.env['API_HOST']}/api/signup'),
              body: jsonEncode(userAcc.toJson()),
              headers: {'Content-Type': 'application/json; charset=UTF-8'},
            );
            switch (res.statusCode) {
              case 200:
                final newUser = userAcc.copyWith(
                  uid: jsonDecode(res.body)['user']['_id'],
                  token: jsonDecode(res.body)['token'],
                );
                localStorageRepo.setToken(newUser.token!);
                ref.read(userProvider.notifier).update((state) => newUser);
            }
            router.push("/home");
          } else if (event is GoogleSignInAuthenticationEventSignOut) {
            ref.read(googleAuthProvider.notifier).state = null;
          }
        },
        onError: (e, _) {
          ref.read(googleErrorProvider.notifier).state = '$e';
        },
      );

      // await signInService.attemptLightweightAuthentication();
    } catch (e) {
      ref.read(googleErrorProvider.notifier).state = '$e';
      sMessenger.showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final signIn = ref.read(googleSignInProvider);
    final lastError = ref.watch(googleErrorProvider);

    // final _user = ref.watch(googleAuthProvider);

    //to show user info when logged in
    // if (_user != null) {
    //   return Row(
    //     mainAxisSize: MainAxisSize.min,
    //     children: [
    //       if (_user!.photoUrl != null)
    //         CircleAvatar(backgroundImage: NetworkImage(_user!.photoUrl!)),
    //       const SizedBox(width: 8),
    //       Text(_user!.email),
    //       const SizedBox(width: 8),
    //       TextButton(
    //         onPressed: () => signIn.signOut(),
    //         child: const Text('Sign out'),
    //       ),
    //     ],
    //   );
    // }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (lastError != null)
              Text(lastError, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: signIn.supportsAuthenticate()
                  ? () => signIn.authenticate()
                  : null,
              child: const Text('Sign in with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
