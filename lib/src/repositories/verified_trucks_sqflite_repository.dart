import 'package:forest_guard/injection.dart';
import 'package:forest_guard/src/entitys/verified_truck_entity.dart';
import 'package:sqflite/sqflite.dart';

abstract class VerifiedTrucksSqfliteRepository {
  Future<List<VerifiedTruckEntity>> getAll();
  Future<int> insert(VerifiedTruckEntity verifiedTruckEntity);
  Future<int> update(VerifiedTruckEntity verifiedTruckEntity);
  void deleteAll();
  void deleteByLicensePlate(String id);
}

class VerifiedTrucksSqfliteRepositoryImpl
    implements VerifiedTrucksSqfliteRepository {
  final Database _database = sl<Database>();

  @override
  Future<List<VerifiedTruckEntity>> getAll() async {
    final raw = await _database.query('verified_trucks');
    return raw.map((e) => VerifiedTruckEntity.fromMap(e)).toList();
  }

  @override
  Future<int> insert(VerifiedTruckEntity verifiedTruckEntity) async {
    return await _database.insert(
        'verified_trucks', verifiedTruckEntity.toMap());
  }

  @override
  Future<int> update(VerifiedTruckEntity verifiedTruckEntity) async {
    return await _database.update(
        'verified_trucks', verifiedTruckEntity.toMap(),
        where: 'id = ?', whereArgs: [verifiedTruckEntity.id]);
  }

  @override
  void deleteAll() {
    _database.delete('verified_trucks');
  }

  @override
  void deleteByLicensePlate(String licensePlate) {
    _database.delete('verified_trucks',
        where: 'licensePlate = ?', whereArgs: [licensePlate]);
  }
}
