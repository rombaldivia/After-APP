import 'package:cloud_firestore/cloud_firestore.dart';

class CustomersRepo {
  CustomersRepo(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _customers =>
      _db.collection('customers');

  Future<DocumentSnapshot<Map<String, dynamic>>> getCustomer(String id) {
    return _customers.doc(id).get();
  }

  Future<String> createCustomer({
    required String merchantId,
    required String fullName,
    String? phone,
  }) async {
    final ref = _customers.doc();
    await ref.set({
      'merchantId': merchantId,
      'fullName': fullName.trim(),
      'phone': (phone == null || phone.trim().isEmpty) ? null : phone.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }
}
