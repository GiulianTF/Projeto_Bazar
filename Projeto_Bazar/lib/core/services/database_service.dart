import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('comandas_bazar.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE casais (
  id $idType,
  nome TEXT,
  qrCode $textType
)
''');

    await db.execute('''
CREATE TABLE comandas (
  id $idType,
  coupleId $textType,
  total $realType,
  status $textType
)
''');

    await db.execute('''
CREATE TABLE itens (
  id $idType,
  comandaId $textType,
  descricao $textType,
  valor $realType,
  quantidade $integerType,
  dataHora $textType
)
''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
