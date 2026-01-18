
import 'package:flutter/foundation.dart';

@immutable
abstract class HomeEvent {}

class HomeTabChanged extends HomeEvent {
  final int index;
  HomeTabChanged(this.index);
}
