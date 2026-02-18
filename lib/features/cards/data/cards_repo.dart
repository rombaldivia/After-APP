import 'package:cloud_firestore/cloud_firestore.dart';

class CardsRepo {
  CardsRepo(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _cards => _db.collection('cards');

  /// Usa el UID NFC como ID de documento.
  Future<DocumentSnapshot<Map<String, dynamic>>> getCard(String cardUidHex) {
    return _cards.doc(cardUidHex).get();
  }

  Future<void> createCard({
    required String cardUidHex,
    required String merchantId,
    required String customerId,
  }) async {
    await _cards.doc(cardUidHex).set({
      'merchantId': merchantId,
      'customerId': customerId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
