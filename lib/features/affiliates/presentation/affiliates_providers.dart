import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/affiliates_repo.dart';
import '../domain/affiliate.dart';

final affiliatesRepoProvider = Provider<AffiliatesRepo>((ref) => AffiliatesRepo());

class AffiliatesNotifier extends StateNotifier<AsyncValue<List<Affiliate>>> {
  AffiliatesNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  final AffiliatesRepo _repo;

  Future<void> load() async {
    try {
      final list = await _repo.getAll();
      state = AsyncValue.data(list);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> upsert(Affiliate a) async {
    await _repo.upsertAffiliate(a);
    await load();
  }
}

final affiliatesNotifierProvider =
    StateNotifierProvider<AffiliatesNotifier, AsyncValue<List<Affiliate>>>((ref) {
  return AffiliatesNotifier(ref.read(affiliatesRepoProvider));
});

// Alias para compatibilidad con affiliates_list_page
final affiliatesListProvider = Provider<AsyncValue<List<Affiliate>>>((ref) {
  return ref.watch(affiliatesNotifierProvider);
});
