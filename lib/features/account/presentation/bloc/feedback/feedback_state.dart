import 'package:flutter/foundation.dart';
import 'package:split_ease/core/enums/app_enums.dart';
export 'package:split_ease/core/enums/app_enums.dart';

@immutable
class FeedbackState {
  final int rating;
  final String description;
  final FeedbackStatus status;
  final String? errorMessage;

  const FeedbackState({
    this.rating = 0,
    this.description = '',
    this.status = FeedbackStatus.initial,
    this.errorMessage,
  });

  FeedbackState copyWith({
    int? rating,
    String? description,
    FeedbackStatus? status,
    String? errorMessage,
  }) {
    return FeedbackState(
      rating: rating ?? this.rating,
      description: description ?? this.description,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
