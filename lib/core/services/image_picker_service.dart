import 'dart:io';
import 'package:image_picker/image_picker.dart';

abstract class ImagePickerService {
  Future<File?> pickImage({ImageSource source = ImageSource.gallery});
}

class ImagePickerServiceImpl implements ImagePickerService {
  final ImagePicker _picker;

  ImagePickerServiceImpl(this._picker);

  @override
  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      // Handle or log error
      return null;
    }
  }
}
