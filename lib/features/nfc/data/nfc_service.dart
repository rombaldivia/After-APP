import 'dart:async';
import 'dart:convert';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';

class NfcScanResult {
  final String uidHex;
  final List<String> techList;

  const NfcScanResult({
    required this.uidHex,
    required this.techList,
  });
}

class NfcService {
  Future<bool> isAvailable() async {
    final a = await NfcManager.instance.checkAvailability();
    return a == NfcAvailability.enabled;
  }

  Future<NfcScanResult> scanOnce({Duration timeout = const Duration(seconds: 12)}) async {
    final ok = await isAvailable();
    if (!ok) {
      throw StateError('NFC no disponible o deshabilitado.');
    }

    final completer = Completer<NfcScanResult>();

    final options = <NfcPollingOption>{
      NfcPollingOption.iso14443,
      NfcPollingOption.iso15693,
      NfcPollingOption.iso18092,
    };

    Timer? timer;
    timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        NfcManager.instance.stopSession();
        completer.completeError(
          TimeoutException('Timeout: no se detectó tarjeta', timeout),
        );
      }
    });

    await NfcManager.instance.startSession(
      pollingOptions: options,
      onDiscovered: (tag) async {
        try {
          final t = NfcTagAndroid.from(tag);

          if (t == null) {
            throw Exception('Tag no es Android o no compatible');
          }

          final uid = _bytesToHex(t.id);
          final techs = t.techList;

          if (!completer.isCompleted) {
            completer.complete(
              NfcScanResult(uidHex: uid, techList: techs),
            );
          }
        } catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        } finally {
          timer?.cancel();
          NfcManager.instance.stopSession();
        }
      },
    );

    return completer.future;
  }

  String _bytesToHex(List<int> bytes) {
    final sb = StringBuffer();
    for (final b in bytes) {
      sb.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return sb.toString().toUpperCase();
  }
}
