import 'package:cloud_firestore/cloud_firestore.dart';

class RedemptionsRepo {
  RedemptionsRepo(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _redemptions =>
      _db.collection('redemptions');

  /// ID compuesto para evitar duplicados: {promoId}_{cardUidHex}
  String redemptionId(String promoId, String cardUidHex) => '${promoId}_$cardUidHex';

  Future<DocumentSnapshot<Map<String, dynamic>>> getRedemption(
    String promoId,
    String cardUidHex,
  ) {
    return _redemptions.doc(redemptionId(promoId, cardUidHex)).get();
  }

  /// Canje irreversible: si existe, lanza error.
  Future<void> redeem({
    required String merchantId,
    required String promoId,
    required String cardUidHex,
    required String customerId,
    required String redeemedByUid,
  }) async {
    final ref = _redemptions.doc(redemptionId(promoId, cardUidHex));

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (snap.exists) {
        throw Exception('Esta promoción ya fue reclamada para esta tarjeta.');
      }
      tx.set(ref, {
        'merchantId': merchantId,
        'promoId': promoId,
        'cardUidHex': cardUidHex,
        'customerId': customerId,
        'redeemed': true,
        'redeemedAt': FieldValue.serverTimestamp(),
        'redeemedByUid': redeemedByUid,
      });
    });
  }
}
