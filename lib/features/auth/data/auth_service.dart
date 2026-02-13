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

  Future<void> initGoogle() async {
    await _google.initialize();
  }

  Future<UserCredential> signInWithGoogle() async {
    await initGoogle();

    if (!_google.supportsAuthenticate()) {
      throw Exception('Plataforma no soporta GoogleSignIn.authenticate().');
    }

    // authenticate() devuelve el usuario (GoogleSignInAccount)
    final user = await _google.authenticate();
    if (user == null) {
      throw Exception('Login cancelado');
    }

    final idToken = user.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('No se pudo obtener idToken');
    }

    final authz = await user.authorizationClient.authorizeScopes(const ['email']);
    final accessToken = authz.accessToken;

    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: accessToken,
    );

    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> registerWithEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> resetPassword(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await _google.disconnect();
    } catch (_) {
      await _google.signOut();
    }
  }
}
