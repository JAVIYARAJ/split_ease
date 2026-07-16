import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'package:split_ease/core/error/exception.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_media_entity.dart';
import 'package:split_ease/core/secrets/app_secrets.dart';

class CloudinaryUploadService {
  static Future<ExpenseMediaEntity> uploadFile(File file) async {
    final cloudName = AppSecrets.cloudinaryCloudName;
    final uploadPreset = AppSecrets.cloudinaryUploadPreset;

    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      throw ServerException(message: 'Cloudinary configuration is missing.');
    }

    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    final isImage = mimeType.startsWith('image/');
    final resourceType = isImage ? 'image' : 'raw';

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      return ExpenseMediaEntity(
        url: jsonResponse['secure_url'],
        publicId: jsonResponse['public_id'],
        mediaType: isImage ? 'image' : 'pdf', // we assume non-image is PDF based on requirements
        fileName: path.basename(file.path),
        mimeType: mimeType,
        fileSize: jsonResponse['bytes'],
        width: jsonResponse['width'],
        height: jsonResponse['height'],
      );
    } else {
      throw ServerException(message: 'Failed to upload media: ${response.body}');
    }
  }

  static Future<void> deleteFile(String publicId, String resourceType) async {
    final cloudName = AppSecrets.cloudinaryCloudName;
    final apiKey = AppSecrets.cloudinaryApiKey;
    final apiSecret = AppSecrets.cloudinaryApiSecret;

    if (cloudName.isEmpty || apiKey.isEmpty || apiSecret.isEmpty) {
      throw ServerException(message: 'Cloudinary configuration is missing for deletion.');
    }

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/$resourceType/destroy');
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round().toString();

    // The signature must include all parameters in alphabetical order except api_key and file
    final signatureString = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
    final signature = sha1.convert(utf8.encode(signatureString)).toString();

    final response = await http.post(uri, body: {
      'public_id': publicId,
      'timestamp': timestamp,
      'api_key': apiKey,
      'signature': signature,
    });

    if (response.statusCode != 200) {
      throw ServerException(message: 'Failed to delete media from Cloudinary: ${response.body}');
    }
  }
}
