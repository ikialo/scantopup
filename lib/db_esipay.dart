
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseRepository {
  static final DatabaseRepository instance = DatabaseRepository._init();
  DatabaseRepository._init();
  Database?_database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('esi.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
create table ${AppConst.tableName} ( 
  ${AppConst.id} integer primary key autoincrement, 
  ${AppConst.title} text not null,
  ${AppConst.Esipaynum} integer not null)
''');
  }

  Future<void> insert({required EsiPayModel todo}) async {
    try {
      final db = await database;
      db.insert(AppConst.tableName, todo.toMap());
    } catch (e) {
      print(e.toString());
    }
  }
  Future<void> delete(int id) async {
    try {
      final db = await instance.database;
      await db.delete(
        AppConst.tableName,
        where: '${AppConst.id} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<EsiPayModel>> getAllTodos() async {
    final db = await instance.database;

    final result = await db.query(AppConst.tableName);

    return result.map((json) => EsiPayModel.fromJson(json)).toList();
  }

}

class AppConst {
  static const String Esipaynum = 'Esipaynum';
  static const String id = 'id';
  static const String title = 'title';
  static const String tableName = 'EsipayTable';
}

class EsiPayModel {
  late final int Esipaynum;
  late final String title;
  late final int id;
  EsiPayModel(
      {required this.title,
        required this.id,
        required this.Esipaynum});


  factory EsiPayModel.fromJson(Map<String, dynamic> map) {
    return EsiPayModel(
      id: map['id'],
      title: map['title'],
      Esipaynum: map['Esipaynum'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'Esipaynum': Esipaynum,
    };
  }
}

