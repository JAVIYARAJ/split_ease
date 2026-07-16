import 'package:equatable/equatable.dart';

class ExpenseMediaEntity extends Equatable {
  final String? id;
  final String url;
  final String publicId;
  final String mediaType; // 'image' or 'pdf'
  final String fileName;
  final String mimeType;
  final int fileSize;
  final int? width;
  final int? height;

  const ExpenseMediaEntity({
    this.id,
    required this.url,
    required this.publicId,
    required this.mediaType,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
    this.width,
    this.height,
  });

  @override
  List<Object?> get props => [
        id,
        url,
        publicId,
        mediaType,
        fileName,
        mimeType,
        fileSize,
        width,
        height,
      ];
}
