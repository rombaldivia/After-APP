import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/nfc_service.dart';
import '../data/card_repo.dart';
import '../../users/data/user_repo.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final nfcServiceProvider = Provider<NfcService>((ref) {
  return NfcService();
});

final cardRepoProvider = Provider<CardRepo>((ref) {
  return CardRepo(ref.watch(firestoreProvider));
});

final userRepoProvider = Provider<UserRepo>((ref) {
  return UserRepo(ref.watch(firestoreProvider));
});
