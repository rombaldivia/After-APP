import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../data/auth_service.dart';

export '../../../core/di/providers.dart' show firebaseAuthProvider;

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(firebaseAuth: ref.watch(firebaseAuthProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

/// UID del usuario logueado (null si no hay sesión)
final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).value?.uid;
});
