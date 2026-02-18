import 'dart:async';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';

class NfcScanResult {
  final String uidHex;
  final List<String> techList;
  const NfcScanResult({required this.uidHex, required this.techList});
}

class NfcService {
  Future<bool> isAvailable() async {
    final a = await NfcManager.instance.checkAvailability();
    return a == NfcAvailability.enabled;
  }

  Future<NfcScanResult> scanOnce(
      {Duration timeout = const Duration(seconds: 12)}) async {
    if (!await isAvailable()) {
      throw StateError('NFC no disponible o deshabilitado.');
    }

    final completer = Completer<NfcScanResult>();
    Timer? timer;

    timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        NfcManager.instance.stopSession();
        completer.completeError(
            TimeoutException('Timeout: no se detectó tarjeta', timeout));
      }
    });

    await NfcManager.instance.startSession(
      pollingOptions: {
        NfcPollingOption.iso14443,
        NfcPollingOption.iso15693,
        NfcPollingOption.iso18092,
      },
      onDiscovered: (tag) async {
        try {
          final t = NfcTagAndroid.from(tag);
          if (t == null) throw Exception('Tag no compatible');
          if (!completer.isCompleted) {
            completer.complete(NfcScanResult(
              uidHex:   _toHex(t.id),
              techList: t.techList,
            ));
          }
        } catch (e) {
          if (!completer.isCompleted) completer.completeError(e);
        } finally {
          timer?.cancel();
          NfcManager.instance.stopSession();
        }
      },
    );

    return completer.future;
  }

  String _toHex(List<int> bytes) => bytes
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join()
      .toUpperCase();
}
