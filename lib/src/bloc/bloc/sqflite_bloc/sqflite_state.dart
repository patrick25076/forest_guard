part of 'sqflite_bloc.dart';

sealed class SqfliteState {}

final class SqfliteInitial extends SqfliteState {}

final class SqfliteLoading extends SqfliteState {}

final class SqfliteLoaded extends SqfliteState {
  final List<VerifiedTruckEntity> data;

  SqfliteLoaded(this.data);
}
