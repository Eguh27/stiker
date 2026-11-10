import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'whatsapp_channel.dart';
import 'whatsapp_staging_exporter.dart';

final whatsAppChannelProvider = Provider<WhatsAppChannel>((ref) {
  return const MethodChannelWhatsAppChannel();
});

final whatsAppStagingExporterProvider = Provider<WhatsAppStagingExporter>((
  ref,
) {
  return const WhatsAppStagingExporter();
});
