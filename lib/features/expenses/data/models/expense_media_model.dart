import 'package:split_ease/features/expenses/domain/entities/expense_media_entity.dart';

class ExpenseMediaModel extends ExpenseMediaEntity {
  const ExpenseMediaModel({
    super.id,
    required super.url,
    required super.publicId,
    required super.mediaType,
    required super.fileName,
    required super.mimeType,
    required super.fileSize,
    super.width,
    super.height,
  });

  factory ExpenseMediaModel.fromJson(Map<String, dynamic> json) {
    return ExpenseMediaModel(
      id: json['id'],
      url: json['url'] ?? '',
      publicId: json['public_id'] ?? '',
      mediaType: json['media_type'] ?? 'image',
      fileName: json['file_name'] ?? '',
      mimeType: json['mime_type'] ?? '',
      fileSize: json['file_size'] ?? 0,
      width: json['width'],
      height: json['height'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'url': url,
      'public_id': publicId,
      'media_type': mediaType,
      'file_name': fileName,
      'mime_type': mimeType,
      'file_size': fileSize,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
    };
  }
}
