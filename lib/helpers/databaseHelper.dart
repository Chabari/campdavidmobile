import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:campdavid/helpers/cartmodel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  //DBHelper._();

  // final DBHelper db = DBHelper._();

  Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "newcartdb.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      
      await db.execute("CREATE TABLE Cartdb ("
          "id INTEGER PRIMARY KEY,"
          "amount TEXT,"
          "quantity TEXT,"
          "productId TEXT,"
          "productname TEXT,"
          "tagId TEXT,"
          "unitName TEXT,"
          "tagName TEXT,"
          "package TEXT,"
          "packageId TEXT,"
          "weight TEXT,"
          "image TEXT,"
          "category TEXT"
          ")");
    });
  }

  Future newCart(OrderItemsModel scan) async {
    final db = await database;

    var raw = await db?.insert(
      'Cartdb',
      scan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return raw;
  }


  Future updateCart(OrderItemsModel cartlist) async {
    final db = await database;
    var res = await db?.update("Cartdb", cartlist.toMap(),
        where: "productId = ? and tagId = ?", whereArgs: [cartlist.productId, cartlist.tagId]);
    return res;
  }

  Future checkexistsItem(String name, tagId) async {
    final db = await database;
    var result = await db?.query('Cartdb', where: 'productId = ? and tagId = ?', whereArgs: [name, tagId]);
    return result;
  }

  Future<List<OrderItemsModel>> getAllCarts() async {
    final db = await database;
    var res = await db?.query("Cartdb");
    List<OrderItemsModel> list =
        res!.isNotEmpty ? res.map((c) => OrderItemsModel.fromMap(c)).toList() : [];
    return list;
  }


  Future deleteCart(String id, String tagId) async {
    final db = await database;
    return db?.delete("Cartdb", where: "productId = ? and tagId = ?", whereArgs: [id, tagId]);
  }
 
  Future deleteAll() async {
    final db = await database;

    return db?.delete("Cartdb");
  }
}