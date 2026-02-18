import '../../affiliates/domain/affiliate.dart';
import '../../../core/local/local_db.dart';

class AffiliatesRepo {
  Future<List<Affiliate>> getAll() async {
    final map = await LocalDb.getAffiliates();
    return map.values.map(Affiliate.fromMap).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<Affiliate?> getByUid(String uidHex) async {
    final data = await LocalDb.getAffiliate(uidHex);
    if (data == null) return null;
    return Affiliate.fromMap(data);
  }

  Future<bool> exists(String uidHex) async {
    return (await LocalDb.getAffiliate(uidHex)) != null;
  }

  Future<void> upsertAffiliate(Affiliate a) async {
    await LocalDb.upsertAffiliate(a.toMap());
  }
}
