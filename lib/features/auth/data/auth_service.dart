import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? google,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _google = google ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _google;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // --- EMAIL/PASSWORD ---
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> resetPassword(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  // --- GOOGLE SIGN-IN (google_sign_in 7.x) ---
  Future<void> initGoogle() async {
    await _google.initialize();
  }

  Future<UserCredential> signInWithGoogle() async {
    await initGoogle();

    try {
      final account = await _google.authenticate();
      final auth = account.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Login Google falló: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _google.signOut();
  }
}
