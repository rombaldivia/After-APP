import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/promos_repo.dart';
import '../domain/promo.dart';

final promosRepoProvider = Provider<PromosRepo>((ref) => PromosRepo());

class PromosNotifier extends StateNotifier<AsyncValue<List<Promo>>> {
  PromosNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  final PromosRepo _repo;

  Future<void> load() async {
    try {
      final list = await _repo.getAll();
      state = AsyncValue.data(list);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> create(Promo p) async {
    await _repo.createPromo(p);
    await load();
  }

  Future<void> toggleActive(String id, bool active) async {
    await _repo.toggleActive(id, active);
    await load();
  }

  Future<void> delete(String id) async {
    await _repo.deletePromo(id);
    await load();
  }
}

final promosNotifierProvider =
    StateNotifierProvider<PromosNotifier, AsyncValue<List<Promo>>>((ref) {
  return PromosNotifier(ref.read(promosRepoProvider));
});

// Alias para compatibilidad
final allPromosProvider = Provider<AsyncValue<List<Promo>>>((ref) {
  return ref.watch(promosNotifierProvider);
});
