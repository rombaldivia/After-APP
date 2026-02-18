import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Base de datos local usando SharedPreferences + JSON.
/// Estructura:
///   after_affiliates  -> { "UID_HEX": { uidHex, name, phone, points } }
///   after_promos      -> [ { id, title, description, pointsReward, active, createdAt } ]
///   after_redemptions -> { "UID_HEX": ["promoId1", "promoId2"] }
class LocalDb {
  static const _kAffiliates  = 'after_affiliates';
  static const _kPromos      = 'after_promos';
  static const _kRedemptions = 'after_redemptions';

  static Future<SharedPreferences> get _p => SharedPreferences.getInstance();

  // ── Affiliates ──────────────────────────────────────────────────────────

  static Future<Map<String, Map<String, dynamic>>> getAffiliates() async {
    final raw = (await _p).getString(_kAffiliates);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)));
  }

  static Future<void> saveAffiliates(Map<String, Map<String, dynamic>> data) async {
    await (await _p).setString(_kAffiliates, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> getAffiliate(String uidHex) async {
    final all = await getAffiliates();
    return all[uidHex];
  }

  static Future<void> upsertAffiliate(Map<String, dynamic> affiliate) async {
    final all = await getAffiliates();
    all[affiliate['uidHex'] as String] = affiliate;
    await saveAffiliates(all);
  }

  // ── Promos ───────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getPromos() async {
    final raw = (await _p).getString(_kPromos);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> savePromos(List<Map<String, dynamic>> data) async {
    await (await _p).setString(_kPromos, jsonEncode(data));
  }

  static Future<String> addPromo(Map<String, dynamic> promo) async {
    final list = await getPromos();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    list.insert(0, {...promo, 'id': id, 'createdAt': DateTime.now().toIso8601String()});
    await savePromos(list);
    return id;
  }

  static Future<void> updatePromo(String id, Map<String, dynamic> changes) async {
    final list = await getPromos();
    final idx = list.indexWhere((p) => p['id'] == id);
    if (idx != -1) {
      list[idx] = {...list[idx], ...changes};
      await savePromos(list);
    }
  }

  static Future<void> deletePromo(String id) async {
    final list = await getPromos();
    list.removeWhere((p) => p['id'] == id);
    await savePromos(list);
  }

  // ── Redemptions ──────────────────────────────────────────────────────────

  static Future<Set<String>> getRedeemedPromos(String uidHex) async {
    final raw = (await _p).getString(_kRedemptions);
    if (raw == null) return {};
    final all = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final list = (all[uidHex] as List<dynamic>?)?.cast<String>() ?? [];
    return list.toSet();
  }

  static Future<void> addRedemption(String uidHex, String promoId) async {
    final p = await _p;
    final raw = p.getString(_kRedemptions);
    final all = raw != null
        ? Map<String, dynamic>.from(jsonDecode(raw) as Map)
        : <String, dynamic>{};
    final current = List<String>.from((all[uidHex] as List<dynamic>?) ?? []);
    if (current.contains(promoId)) throw Exception('Ya canjeaste esta promoción.');
    current.add(promoId);
    all[uidHex] = current;
    await p.setString(_kRedemptions, jsonEncode(all));
  }

  static Future<void> addPoints(String uidHex, int points) async {
    final all = await getAffiliates();
    if (all.containsKey(uidHex)) {
      final current = (all[uidHex]!['points'] as int?) ?? 0;
      all[uidHex]!['points'] = current + points;
      await saveAffiliates(all);
    }
  }
}
