import '../../core/db/daos/lotes_dao.dart';
import '../../core/db/database.dart';

/// Única superficie que los bloques de `features/` deben usar para tocar
/// lotes; ninguno debe importar `core/db` directamente.
class LotesRepository {
  LotesRepository(this._dao);

  final LotesDao _dao;

  Stream<List<Lote>> watchLotes() => _dao.watchAllLotes();

  Future<Lote> getLoteById(int id) => _dao.getLoteById(id);

  Future<int> crearLote(String nombre) =>
      _dao.insertLote(LotesCompanion.insert(nombre: nombre));
}
