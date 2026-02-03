import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<File> saveBytesToFile(Uint8List bytes, String fileName) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    return await file.writeAsBytes(bytes);
  }
}
