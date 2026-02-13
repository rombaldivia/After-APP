import 'dart:async';
import 'dart:convert';
import 'package:nfc_manager/nfc_manager.dart';

class NfcService {
  Future<bool> isEnabled() async {
    final availability = await NfcManager.instance.checkAvailability();
    return availability == NfcAvailability.enabled;
  }

  Future<String> scanOnce({Duration timeout = const Duration(seconds: 12)}) async {
    final available = await isEnabled();
    if (!available) {
      throw Exception('NFC no disponible');
    }

    final completer = Completer<String>();

    await NfcManager.instance.startSession(
      pollingOptions: const {
        NfcPollingOption.iso14443,
        NfcPollingOption.iso15693,
        NfcPollingOption.iso18092,
      },
      onDiscovered: (NfcTag tag) async {
        try {
          final id = _extractTagIdHex(tag);
          await NfcManager.instance.stopSession(); // SIN errorMessage
          if (!completer.isCompleted) {
            completer.complete(id);
          }
        } catch (e) {
          await NfcManager.instance.stopSession();
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        }
      },
    );

    return completer.future.timeout(
      timeout,
      onTimeout: () async {
        await NfcManager.instance.stopSession();
        throw Exception('Tiempo agotado');
      },
    );
  }

  String _extractTagIdHex(NfcTag tag) {
    final dynamic raw = tag.data;

    if (raw is Map) {
      final id = raw['id'];
      if (id is List) {
        return _toHex(id.cast<int>());
      }

      final nfca = raw['nfca'];
      if (nfca is Map) {
        final ident = nfca['identifier'];
        if (ident is List) {
          return _toHex(ident.cast<int>());
        }
      }
    }

    return 'TAG-${tag.hashCode}';
  }

  String _toHex(List<int> bytes) {
    final buffer = StringBuffer();
    for (final b in bytes) {
      buffer.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString().toUpperCase();
  }

  String toBase64(String s) => base64UrlEncode(utf8.encode(s));
}
