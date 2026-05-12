import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dash/models/car.dart';
import 'package:dash/models/txn.dart';

//https://suragch.medium.com/simple-sqflite-database-example-in-flutter-e56a5aaa3f91
// class dbWrapper {
//   if (Platform.isWindows or Platform.isLinux or ) {
//     print('build does not support sqlite')
//   }
// }

class DbHelperSqlite {
  final _dbName = "cars_sqlite.db";
  final _dbVersion = 1;

  // make singleton class
  DbHelperSqlite._privateConstructor();
  static final DbHelperSqlite instance = DbHelperSqlite._privateConstructor();
  static Database? _database;

  Future<Database?> get database async {
    _database = await _initDatabase();
    return _database!;
  }

  // open db and create if not exists
  _initDatabase() async {
    print('initializing db');
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(documentsDirectory.path, _dbName);
    print('sqlite db path: $dbPath');
    return await openDatabase(dbPath, version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    //docs say to avoid `autoincrement` kw
    await db.execute("PRAGMA foreign_keys=ON;");
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${Car.tblCars} (
        ${Car.colId} INTEGER PRIMARY KEY,
        ${Car.colVin} TEXT UNIQUE,
        ${Car.colNickname} TEXT,
        ${Car.colMileage} INTEGER,
        ${Car.colPlate} TEXT,
        ${Car.colIcon} TEXT);
        ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${Txn.tblTxns} (
        ${Txn.colId} INTEGER PRIMARY KEY,
        ${Txn.colType} TEXT,
        ${Txn.colDatetime} INTEGER,
        ${Txn.colCost} REAL,
        ${Txn.colMileage} INTEGER,
        ${Txn.colNote} TEXT,
        ${Txn.colCarId} INTEGER,
        FOREIGN KEY(${Txn.colCarId}) REFERENCES ${Car.tblCars}(${Car.colId}));
        ''');
  }

  Future<Map<String, dynamic>> _carMapForDatabase(Database db, Car car) async {
    final map = car.toMap();
    final columns = await db.rawQuery("PRAGMA table_info(${Car.tblCars})");
    final hasIconColumn =
        columns.any((column) => column['name'] == Car.colIcon);
    if (!hasIconColumn) {
      map.remove(Car.colIcon);
    }
    return map;
  }

  Future<int> insertCar(Car car) async {
    Database db = await instance.database as Database;
    return await db.insert(Car.tblCars, await _carMapForDatabase(db, car),
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<List<Car>> fetchCars() async {
    Database db = await database as Database;
    List<Map<String, dynamic>> cars = await db.query(Car.tblCars);
    if (cars.isEmpty) {
      return [];
    } else {
      return cars.map((car) => Car.fromMap(car)).toList();
    }
  }

  Future<int> updateCar(Car car) async {
    Database db = await instance.database as Database;
    print('car id to update: ${car.id}');
    return await db.update(Car.tblCars, await _carMapForDatabase(db, car),
        where: '${Car.colId}=?', whereArgs: [car.id]);
  }

  Future<int> deleteCar(Car car) async {
    Database db = await instance.database as Database;
    print('car id to delete: ${car.id}');
    return await db
        .delete(Car.tblCars, where: '${Car.colId}=?', whereArgs: [car.id]);
  }

  Future<int> deleteAllCars() async {
    Database db = await instance.database as Database;
    return await db.rawDelete("DELETE FROM ${Car.tblCars}");
  }

  Future<int> insertTxn(Txn txn) async {
    Database db = await instance.database as Database;
    print('adding txn ${txn.txntype} at ${txn.datetime}');
    return await db.insert(Txn.tblTxns, txn.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

/*   Future<List<Txn>> fetchTxns(int carid, {txntype = '*'}) async {
    Database db = await instance.database as Database;
    List<Map<String, dynamic>> txns = await db.query(Txn.tblTxns,
        where: '${Txn.colCarId}=? and ${Txn.colType}=?',
        whereArgs: [carid, txntype]);
    if (txns.isEmpty) {
      return [];
    } else {
      return txns.map((txn) => Txn.fromMap(txn)).toList();
    }
  } */
  Future<List<Txn>> fetchTxns(int carid) async {
    Database db = await instance.database as Database;
    List<Map<String, dynamic>> txns = await db
        .query(Txn.tblTxns, where: '${Txn.colCarId}=?', whereArgs: [carid]);
    if (txns.isEmpty) {
      return [];
    } else {
      return txns.map((txn) => Txn.fromMap(txn)).toList();
    }
  }

  Future<int> deleteTxn(Txn txn) async {
    Database db = await instance.database as Database;
    print('txn id to delete: ${txn.id}');
    return await db
        .delete(Txn.tblTxns, where: '${Txn.colId}=?', whereArgs: [txn.id]);
  }

  Future<int> deleteAllTxns() async {
    Database db = await instance.database as Database;
    return await db.rawDelete("DELETE FROM ${Txn.tblTxns}");
  }
}

// flutter ex: https://docs.flutter.dev/cookbook/persistence/sqlite
/*   Future<void> insertCar(Car car) async {
    final db = await database;
    await db.insert(
      'cars',
      car.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  } */

/*   Future<void> insertTestCar(Car car) async {
    final db = await database;
    await db.insert('cars', car.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort);
  }


  Future<int> deleteCar(String vin) async {
    Database db = await instance.database;
    return await db.delete(tableCars, where: '$colVin=?', whereArgs: [vin]);
  }

  Future<List<Map<String, dynamic>>> queryAllCars() async {
    Database db = await instance.database;
    return await db.query(tableCars);
  }
} */
