import 'package:drift/drift.dart' show Value;

import '../../core/db/daos/lotes_dao.dart';
import '../../core/db/database.dart';

/// Única superficie que los bloques de `features/` deben usar para tocar
/// lotes; ninguno debe importar `core/db` directamente.
class LotesRepository {
  LotesRepository(this._dao);

  final LotesDao _dao;

  Stream<List<Lote>> watchLotes() => _dao.watchAllLotes();

  Future<Lote> getLoteById(int id) => _dao.getLoteById(id);

  Future<int> crearLote(String nombre) async {
    // Un lote nuevo siempre queda arriba de todo, nunca antes de los que
    // ya existen.
    final orden = await _dao.obtenerSiguienteOrden();
    return _dao.insertLote(
      LotesCompanion.insert(nombre: nombre, orden: Value(orden)),
    );
  }

  Future<bool> renombrarLote(Lote lote, String nuevoNombre) =>
      _dao.updateLote(lote.copyWith(nombre: nuevoNombre));

  Future<int> eliminarLote(int id) => _dao.deleteLote(id);

  Future<void> reordenarLotes(List<int> idsEnNuevoOrden) =>
      _dao.reordenarLotes(idsEnNuevoOrden);
}
