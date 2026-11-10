import 'package:flutter/services.dart';

abstract class WhatsAppChannel {
  Future<bool> isWhatsAppInstalled({bool business = false});
  Future<bool> addStickerPack({
    required String identifier,
    required String name,
    bool isBusiness = false,
  });
  Future<String> getStagingDirectory();
}

class MethodChannelWhatsAppChannel implements WhatsAppChannel {
  const MethodChannelWhatsAppChannel([
    this._channel = const MethodChannel('com.example.sticker_studio/whatsapp'),
  ]);

  final MethodChannel _channel;

  @override
  Future<bool> isWhatsAppInstalled({bool business = false}) async {
    try {
      final res = await _channel.invokeMethod<bool>('isWhatsAppInstalled', {
        'package': business ? 'com.whatsapp.w4b' : 'com.whatsapp',
      });
      return res ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> addStickerPack({
    required String identifier,
    required String name,
    bool isBusiness = false,
  }) async {
    try {
      final res = await _channel.invokeMethod<bool>('addStickerPack', {
        'identifier': identifier,
        'name': name,
        'isBusiness': isBusiness,
      });
      return res ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<String> getStagingDirectory() async {
    try {
      final res = await _channel.invokeMethod<String>('getStagingDirectory');
      return res ??
          '/data/user/0/com.example.sticker_studio/files/wa_export_staging';
    } on PlatformException {
      return '/data/user/0/com.example.sticker_studio/files/wa_export_staging';
    }
  }
}
