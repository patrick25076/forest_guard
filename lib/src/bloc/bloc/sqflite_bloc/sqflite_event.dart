part of 'sqflite_bloc.dart';

sealed class SqfliteEvent {}

final class SqfliteGetAll extends SqfliteEvent {}

final class SqfliteInsert extends SqfliteEvent {
  final VerifiedTruckEntity verifiedTruckEntity;

  SqfliteInsert({required this.verifiedTruckEntity});
}

final class SqfliteUpdate extends SqfliteEvent {
  final Map<String, dynamic> row;

  SqfliteUpdate(this.row);
}

final class SqfliteDelete extends SqfliteEvent {
  final int id;

  SqfliteDelete(this.id);
}

final class SqfliteDeleteAll extends SqfliteEvent {}

//delete By ID
final class SqfliteDeleteByLicensePlate extends SqfliteEvent {
  final String licensePlate;

  SqfliteDeleteByLicensePlate(this.licensePlate);
}
