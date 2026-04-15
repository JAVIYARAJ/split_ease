import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/features/account/domain/usecases/submit_app_feedback_usecase.dart';
import 'feedback_state.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  final SubmitAppFeedbackUseCase _submitAppFeedbackUseCase;

  FeedbackCubit(this._submitAppFeedbackUseCase) : super(const FeedbackState());

  void updateRating(int rating) {
    emit(state.copyWith(rating: rating, status: FeedbackStatus.initial, errorMessage: null));
  }

  void updateDescription(String description) {
    emit(state.copyWith(description: description, status: FeedbackStatus.initial, errorMessage: null));
  }

  Future<void> submitFeedback() async {
    if (state.rating == 0 && state.description.trim().isEmpty) {
      emit(state.copyWith(
        status: FeedbackStatus.failure,
        errorMessage: 'Please provide a rating or some feedback.',
      ));
      return;
    }

    emit(state.copyWith(status: FeedbackStatus.loading));

    final result = await _submitAppFeedbackUseCase(
      SubmitAppFeedbackParams(rating: state.rating, description: state.description),
    );

    result.fold(
      (failure) => emit(state.copyWith(status: FeedbackStatus.failure, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: FeedbackStatus.success)),
    );
  }
}
