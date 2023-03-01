import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart' as tx;

class TransactionDatabase {
  static final TransactionDatabase instance = TransactionDatabase._init();
  static Database? _database;
  TransactionDatabase._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB("transactions.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = "INTEGER PRIMARY KEY AUTOINCREMENT";
    final boolType = "BOOLEAN NOT NULL";
    final intType = "INTEGER NOT NULL";
    final textType = "TEXT NOT NULL";

    await db.execute('''
    CREATE TABLE ${tx.tableTransactions} (
       ${tx.TransactionFields.id} $idType,
       ${tx.TransactionFields.title} $textType,
       ${tx.TransactionFields.amount} $textType,
       ${tx.TransactionFields.date} $textType
    )
    ''');
  }

  Future create(tx.Transaction transaction) async {
    final db = await instance.database;

    // final json = note.toJson();
    // final columns =
    //     '${NoteFields.title}, ${NoteFields.description}, ${NoteFields.time}';
    // final values =
    //     '${json[NoteFields.title]}, ${json[NoteFields.description]}, ${json[NoteFields.time]}';

    // final id = await db.rawInsert('''INSERT INTO $tableNotes
    //      ($columns)
    //      VALUES ($values)''');

    final id = await db.insert(
      tx.tableTransactions,
      transaction.toJson(),
    );
    return transaction.copy(id: id);
  }

  Future<tx.Transaction> readTransaction(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tx.tableTransactions,
      columns: tx.TransactionFields.values,
      where: "${tx.TransactionFields.id} = ?",
      whereArgs: [id],
      // alternative of where: "${NoteFields.id} = $id", cause: Prevents SQL Injection attack
    );
    if (maps.isNotEmpty) {
      return tx.Transaction.fromJson(maps.first);
    } else {
      throw Exception("ID $id not found");
    }
  }

  Future<List<tx.Transaction>> readAllTransactions() async {
    final db = await instance.database;
    final orderBy = "${tx.TransactionFields.date} ASC";
    //final result = await db.rawQuery("SELECT * FROM $tableNotes ORDER BY $orderBy");
    final result = await db.query(tx.tableTransactions, orderBy: orderBy);

    return result.map((json) => tx.Transaction.fromJson(json)).toList();
  }

  Future<int> update(tx.Transaction transaction) async {
    final db = await instance.database;

    return db.update(
      tx.tableTransactions,
      transaction.toJson(),
      where: "${tx.TransactionFields.id} = ?",
      whereArgs: [transaction.id],
      //also can use rawUpdate
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return db.delete(
      tx.tableTransactions,
      where: "${tx.TransactionFields.id} = ?",
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
