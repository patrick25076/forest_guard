import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:forest_guard/forest_guard_app.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:forest_guard/injection.dart' as di;
import 'package:sqflite/sqflite.dart';

void mainInit() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Open the database and store the reference.
  final appDirectory = await getApplicationDocumentsDirectory();
  final database = await openForestGuardDatabase(appDirectory);
  await di.init(database);
  runApp(const ForestGuardApp());
}

Future<Database> openForestGuardDatabase(Directory appDirectory) {
  return openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(appDirectory.path, 'forest_guard.db'),
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE verified_trucks(id INTEGER PRIMARY KEY, timestamp DATETIME, licensePlate TEXT, legalWoodVolume DOUBLE, estimatedWoodVolume DOUBLE)',
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
}
