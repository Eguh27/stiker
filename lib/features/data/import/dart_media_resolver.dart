import 'dart:convert';
import 'dart:io';

/// Fallback resolver menggunakan Dart [HttpClient] untuk mengunduh gambar
/// langsung dari web (termasuk Pinterest dan og:image).
Future<bool> downloadMediaWithDart({
  required String url,
  required String outputPath,
}) async {
  final client = HttpClient();
  client.userAgent = 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36';
  client.connectionTimeout = const Duration(seconds: 15);

  try {
    final uri = Uri.tryParse(url);
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      return false;
    }

    final request = await client.getUrl(uri);
    request.headers.set(
      HttpHeaders.acceptHeader,
      'image/*,text/html;q=0.9,*/*;q=0.1',
    );
    final response = await request.close();

    final contentType =
        response.headers.contentType?.mimeType.toLowerCase() ?? '';

    // Jika response langsung bertipe image: simpan langsung
    if (contentType.startsWith('image/')) {
      final file = File(outputPath);
      final sink = file.openWrite();
      await response.pipe(sink);
      return await file.exists() && await file.length() > 0;
    }

    // Jika response berupa HTML: cari og:image atau URL pinimg
    final html = await utf8.decodeStream(response);
    final imageUrl = _findImageUrlInHtml(html);
    if (imageUrl != null) {
      final imgUri = Uri.tryParse(imageUrl);
      if (imgUri != null) {
        final imgReq = await client.getUrl(imgUri);
        imgReq.headers.set(HttpHeaders.acceptHeader, 'image/*,*/*;q=0.8');
        final imgRes = await imgReq.close();
        if (imgRes.statusCode == HttpStatus.ok) {
          final file = File(outputPath);
          final sink = file.openWrite();
          await imgRes.pipe(sink);
          return await file.exists() && await file.length() > 0;
        }
      }
    }
  } catch (_) {
    return false;
  } finally {
    client.close();
  }
  return false;
}

String? _findImageUrlInHtml(String html) {
  // 1. og:image meta tag
  final ogMatch =
      RegExp(
        r'''<meta\s+[^>]*property=["']og:image["'][^>]*content=["']([^"']+)["']''',
        caseSensitive: false,
      ).firstMatch(html) ??
      RegExp(
        r'''<meta\s+[^>]*content=["']([^"']+)["'][^>]*property=["']og:image["']''',
        caseSensitive: false,
      ).firstMatch(html);

  if (ogMatch != null) {
    return ogMatch.group(1);
  }

  // 2. Pinterest pinimg regex
  final pinMatch = RegExp(
    r'''https?://i\.pinimg\.com/(?:originals|736x|564x)/[^\s"'<>]+''',
    caseSensitive: false,
  ).firstMatch(html);

  if (pinMatch != null) {
    return pinMatch.group(0);
  }

  return null;
}
