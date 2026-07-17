import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/lotes_table.dart';

part 'lotes_dao.g.dart';

@DriftAccessor(tables: [Lotes])
class LotesDao extends DatabaseAccessor<AppDatabase> with _$LotesDaoMixin {
  LotesDao(super.db);

  Stream<List<Lote>> watchAllLotes() =>
      (select(lotes)
            ..orderBy([
              (t) => OrderingTerm.desc(t.orden),
              (t) => OrderingTerm.desc(t.id),
            ]))
          .watch();

  Future<Lote> getLoteById(int id) =>
      (select(lotes)..where((t) => t.id.equals(id))).getSingle();

  /// Siguiente valor de `orden` disponible para un lote nuevo: al ser el
  /// más alto, y mostrarse la lista de mayor a menor, el lote nuevo queda
  /// arriba de todo (igual que antes, cuando se ordenaba por fecha).
  Future<int> obtenerSiguienteOrden() async {
    final query = selectOnly(lotes)..addColumns([lotes.orden.max()]);
    final fila = await query.getSingleOrNull();
    final maximo = fila?.read(lotes.orden.max());
    return (maximo ?? -1) + 1;
  }

  Future<int> insertLote(LotesCompanion entry) => into(lotes).insert(entry);

  Future<bool> updateLote(Lote lote) => update(lotes).replace(lote);

  Future<int> deleteLote(int id) =>
      (delete(lotes)..where((t) => t.id.equals(id))).go();

  /// Persiste un nuevo orden manual: [idsEnNuevoOrden] es la lista completa
  /// de ids en el orden en que deben quedar mostrados de arriba a abajo (el
  /// primero recibe el `orden` más alto, ya que la lista se muestra
  /// descendente).
  Future<void> reordenarLotes(List<int> idsEnNuevoOrden) {
    final total = idsEnNuevoOrden.length;
    return batch((b) {
      for (var i = 0; i < total; i++) {
        b.update(
          lotes,
          LotesCompanion(orden: Value(total - 1 - i)),
          where: (t) => t.id.equals(idsEnNuevoOrden[i]),
        );
      }
    });
  }
}
