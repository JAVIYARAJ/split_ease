import 'package:equatable/equatable.dart';

class AdvertisementEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String imageUrl;
  final String? ctaText;
  final String? ctaUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final int priority;

  const AdvertisementEntity({
    required this.id,
    required this.title,
    this.description,
    required this.imageUrl,
    this.ctaText,
    this.ctaUrl,
    this.startDate,
    this.endDate,
    this.priority = 0,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        ctaText,
        ctaUrl,
        startDate,
        endDate,
        priority,
      ];
}
