import 'package:google_docs/models/user_model.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

final googleAuthProvider = StateProvider<GoogleSignInAccount?>((ref) => null);

final googleErrorProvider = StateProvider<String?>((ref) => null);

final googleSignInProvider = StateProvider<GoogleSignIn>((ref) {
  return GoogleSignIn.instance;
});

final googleWebSignInPlatformProvider = StateProvider<GoogleSignInPlatform>((
  ref,
) {
  return GoogleSignInPlatform.instance;
});

final userServiceProvider = Provider<UserService>((ref) => UserService());

final initUserProvider = FutureProvider<void>((ref) async {
  await _fetchAndSetUserDataFromRef(ref);
});

Future<void> _fetchAndSetUserDataFromRef(ref) async {
  final service = ref.read(userServiceProvider);

  try {
    final user = await service.getUserData();
    if (user != null) {
      ref.read(userProvider.notifier).state = user;
    }
  } catch (e, st) {
    print("fetchAndSetUserData error: $e\n$st");
    // Optional: log or set an error state
  }
}

Future<void> fetchAndSetUserData(WidgetRef widgetRef) =>
    _fetchAndSetUserDataFromRef(widgetRef);
