import 'package:sqflite/sqflite.dart';
import '../../../../core/services/database_service.dart';
import '../../../../shared/models/comanda_model.dart';
import '../../../../shared/models/comanda_status.dart';
import '../../../../shared/models/item_model.dart';
import '../../../../shared/models/pagamento_model.dart';

class ComandaLocalService {
  final DatabaseService _dbService = DatabaseService.instance;

  Future<ComandaModel?> getComandaAtivaPorCasal(String coupleId) async {
    final db = await _dbService.database;
    
    final maps = await db.query(
      'comandas',
      where: 'coupleId = ? AND status != ?',
      whereArgs: [coupleId, ComandaStatus.paga.toMap()],
    );

    if (maps.isNotEmpty) {
      final comandaMap = maps.first;
      final String id = comandaMap['id'] as String;
      final itens = await getItensPorComanda(id);
      final pagamentos = await getPagamentosPorComanda(id);
      
      return ComandaModel.fromMap(comandaMap, itens: itens, pagamentos: pagamentos);
    }
    return null;
  }

  Future<List<ItemModel>> getItensPorComanda(String comandaId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'itens',
      where: 'comandaId = ?',
      whereArgs: [comandaId],
      orderBy: 'dataHora DESC',
    );
    return maps.map((e) => ItemModel.fromMap(e)).toList();
  }
  
  Future<List<PagamentoModel>> getPagamentosPorComanda(String comandaId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pagamentos',
      where: 'comandaId = ?',
      whereArgs: [comandaId],
      orderBy: 'dataHora DESC',
    );
    return maps.map((e) => PagamentoModel.fromMap(e)).toList();
  }

  Future<void> createComanda(ComandaModel comanda) async {
    final db = await _dbService.database;
    await db.insert('comandas', comanda.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateComanda(ComandaModel comanda) async {
    final db = await _dbService.database;
    await db.update('comandas', comanda.toMap(), where: 'id = ?', whereArgs: [comanda.id]);
  }

  Future<void> saveItem(ItemModel item) async {
    final db = await _dbService.database;
    await db.insert('itens', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  Future<void> savePagamento(PagamentoModel pagamento) async {
    final db = await _dbService.database;
    await db.insert('pagamentos', pagamento.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
