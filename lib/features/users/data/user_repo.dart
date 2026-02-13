import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepo {
  UserRepo(this.db);
  final FirebaseFirestore db;

  Future<Map<String, dynamic>?> getUser(String userId) async {
    final snap = await db.collection('users').doc(userId).get();
    return snap.data();
  }

  Future<String> createUser({
    required String displayName,
    int points = 0,
    String tier = 'GOLD',
  }) async {
    final ref = db.collection('users').doc();
    await ref.set({
      'displayName': displayName,
      'points': points,
      'tier': tier,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> updatePoints(String userId, int newPoints) async {
    await db.collection('users').doc(userId).update({
      'points': newPoints,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
