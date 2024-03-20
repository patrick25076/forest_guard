import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forest_guard/src/entitys/verified_truck_entity.dart';
import 'package:forest_guard/src/repositories/verified_trucks_sqflite_repository.dart';

part 'sqflite_event.dart';
part 'sqflite_state.dart';

class SqfliteBloc extends Bloc<SqfliteEvent, SqfliteState> {
  VerifiedTrucksSqfliteRepository sqfliteRepository;

  SqfliteBloc({required this.sqfliteRepository}) : super(SqfliteInitial()) {
    on<SqfliteInsert>((event, emit) async {
      emit(SqfliteLoading());
      await sqfliteRepository.insert(event.verifiedTruckEntity);
      await sqfliteRepository.getAll().then((value) {
        emit(SqfliteLoaded(value));
      });
    });

    on<SqfliteGetAll>((event, emit) async {
      emit(SqfliteLoading());

      await sqfliteRepository.getAll().then((value) {
        emit(SqfliteLoaded(value));
      });
    });

    on<SqfliteDeleteAll>((event, emit) async {
      emit(SqfliteLoading());
      sqfliteRepository.deleteAll();
      await sqfliteRepository.getAll().then((value) {
        emit(SqfliteLoaded(value));
      });
    });

    on<SqfliteDeleteByLicensePlate>((event, emit) async {
      emit(SqfliteLoading());
      sqfliteRepository.deleteByLicensePlate(event.licensePlate);
      await sqfliteRepository.getAll().then((value) {
        emit(SqfliteLoaded(value));
      });
    });
  }
}
