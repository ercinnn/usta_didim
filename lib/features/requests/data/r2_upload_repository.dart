import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Uploads a service request photo directly to Cloudflare R2 using a
/// short-lived presigned URL minted by the `r2-presigned-upload` Edge
/// Function -- R2 credentials never touch the client. Returns the object's
/// public URL to store in `service_requests.photo_urls`.
class R2UploadRepository {
  const R2UploadRepository(this._client);

  final SupabaseClient _client;

  Future<String> uploadPhoto({
    required Uint8List bytes,
    required String contentType,
  }) async {
    final response = await _client.functions.invoke(
      'r2-presigned-upload',
      body: {'contentType': contentType},
    );
    final data = response.data as Map<String, dynamic>;
    final uploadUrl = data['uploadUrl'] as String;
    final publicUrl = data['publicUrl'] as String;

    final putResponse = await http.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': contentType},
      body: bytes,
    );
    if (putResponse.statusCode != 200) {
      throw Exception('Fotoğraf yüklenemedi (${putResponse.statusCode})');
    }
    return publicUrl;
  }
}
