import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../affiliates/data/affiliates_repo.dart';
import '../../affiliates/domain/affiliate.dart';
import '../../promos/data/promos_repo.dart';
import '../../promos/domain/promo.dart';
import '../data/nfc_service.dart';

final _affiliatesRepoProvider = Provider<AffiliatesRepo>((ref) => AffiliatesRepo());
final _promosRepoProvider     = Provider<PromosRepo>((ref) => PromosRepo());
final nfcServiceProvider      = Provider<NfcService>((ref) => NfcService());

enum ScanStep { idle, scanning, notFound, showingUser }

class ScanFlowState {
  final ScanStep step;
  final String?  uidHex;
  final Affiliate? affiliate;
  final List<PromoWithStatus> promos;
  final String? error;
  final String? successMsg;

  const ScanFlowState({
    this.step = ScanStep.idle,
    this.uidHex,
    this.affiliate,
    this.promos = const [],
    this.error,
    this.successMsg,
  });

  ScanFlowState copyWith({
    ScanStep? step,
    String?   uidHex,
    Affiliate? affiliate,
    List<PromoWithStatus>? promos,
    String? error,
    String? successMsg,
    bool clearError   = false,
    bool clearSuccess = false,
  }) => ScanFlowState(
    step:       step       ?? this.step,
    uidHex:     uidHex     ?? this.uidHex,
    affiliate:  affiliate  ?? this.affiliate,
    promos:     promos     ?? this.promos,
    error:      clearError   ? null : (error      ?? this.error),
    successMsg: clearSuccess ? null : (successMsg ?? this.successMsg),
  );
}

class NfcScanController extends StateNotifier<ScanFlowState> {
  NfcScanController(this._ref) : super(const ScanFlowState());

  final Ref _ref;

  NfcService    get _nfc       => _ref.read(nfcServiceProvider);
  AffiliatesRepo get _affiliates => _ref.read(_affiliatesRepoProvider);
  PromosRepo     get _promos    => _ref.read(_promosRepoProvider);

  Future<void> scanAndLookup() async {
    state = state.copyWith(step: ScanStep.scanning, clearError: true, clearSuccess: true);

    try {
      final result    = await _nfc.scanOnce(timeout: const Duration(seconds: 15));
      final uid       = result.uidHex;
      final affiliate = await _affiliates.getByUid(uid);

      if (affiliate == null) {
        state = state.copyWith(step: ScanStep.notFound, uidHex: uid);
      } else {
        await _loadPromos(affiliate);
      }
    } catch (e) {
      state = state.copyWith(step: ScanStep.idle, error: 'Error al escanear: $e');
    }
  }

  Future<void> createAffiliate({required String name, String? phone}) async {
    final uid = state.uidHex;
    if (uid == null) return;
    state = state.copyWith(step: ScanStep.scanning, clearError: true);
    try {
      final a = Affiliate(
        uidHex: uid,
        name: name,
        phone: (phone?.isEmpty ?? true) ? null : phone,
      );
      await _affiliates.upsertAffiliate(a);
      await _loadPromos(a);
    } catch (e) {
      state = state.copyWith(step: ScanStep.notFound, error: 'Error: $e');
    }
  }

  Future<void> _loadPromos(Affiliate affiliate) async {
    final promos = await _promos.getPromosWithStatus(affiliate.uidHex);
    state = state.copyWith(
      step:      ScanStep.showingUser,
      uidHex:    affiliate.uidHex,
      affiliate: affiliate,
      promos:    promos,
      clearError: true,
    );
  }

  Future<void> redeem(String promoId, int pointsReward) async {
    final uid = state.affiliate?.uidHex;
    if (uid == null) return;

    // Optimistic update
    final updated = state.promos.map((ps) => ps.promo.id == promoId
        ? PromoWithStatus(promo: ps.promo, redeemed: true)
        : ps).toList();
    state = state.copyWith(promos: updated, clearError: true, clearSuccess: true);

    try {
      await _promos.redeem(uid, promoId, pointsReward: pointsReward);
      // Recargar afiliado para mostrar puntos actualizados
      final updatedAffiliate = await _affiliates.getByUid(uid);
      state = state.copyWith(
        successMsg: '¡Promoción canjeada!',
        affiliate: updatedAffiliate,
      );
    } catch (e) {
      final reverted = state.promos.map((ps) => ps.promo.id == promoId
          ? PromoWithStatus(promo: ps.promo, redeemed: false)
          : ps).toList();
      state = state.copyWith(promos: reverted, error: 'Error: $e');
    }
  }

  void reset() => state = const ScanFlowState();
}

final nfcScanControllerProvider =
    StateNotifierProvider.autoDispose<NfcScanController, ScanFlowState>((ref) {
  return NfcScanController(ref);
});
