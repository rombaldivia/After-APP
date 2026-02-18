import '../../../core/local/local_db.dart';
import '../domain/promo.dart';

class PromosRepo {
  Future<List<Promo>> getAll() async {
    final list = await LocalDb.getPromos();
    return list.map(Promo.fromMap).toList();
  }

  Future<List<Promo>> getActive() async {
    final list = await getAll();
    return list.where((p) => p.active).toList();
  }

  Future<String> createPromo(Promo promo) async {
    return LocalDb.addPromo(promo.toLocalMap());
  }

  Future<void> toggleActive(String id, bool active) async {
    await LocalDb.updatePromo(id, {'active': active});
  }

  Future<void> deletePromo(String id) async {
    await LocalDb.deletePromo(id);
  }

  Future<List<PromoWithStatus>> getPromosWithStatus(String uidHex) async {
    final promos = await getActive();
    final redeemed = await LocalDb.getRedeemedPromos(uidHex);
    return promos
        .map((p) => PromoWithStatus(promo: p, redeemed: redeemed.contains(p.id)))
        .toList();
  }

  Future<void> redeem(String uidHex, String promoId, {int pointsReward = 0}) async {
    await LocalDb.addRedemption(uidHex, promoId);
    if (pointsReward > 0) {
      await LocalDb.addPoints(uidHex, pointsReward);
    }
  }
}
