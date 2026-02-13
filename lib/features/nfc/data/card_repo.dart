import 'package:cloud_firestore/cloud_firestore.dart';

class CardRepo {
  CardRepo(this.db);
  final FirebaseFirestore db;

  Future<String?> getUserIdForCard(String cardId) async {
    final snap = await db.collection('cards').doc(cardId).get();
    final data = snap.data();
    return data?['userId'] as String?;
  }

  Future<void> linkCardToUser({
    required String cardId,
    required String userId,
  }) async {
    await db.collection('cards').doc(cardId).set({
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
