import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/articulos_table.dart';

part 'articulos_dao.g.dart';

@DriftAccessor(tables: [Articulos])
class ArticulosDao extends DatabaseAccessor<AppDatabase>
    with _$ArticulosDaoMixin {
  ArticulosDao(super.db);

  Stream<List<Articulo>> watchArticulosByLote(int loteId) =>
      (select(articulos)
            ..where((t) => t.loteId.equals(loteId))
            ..orderBy([
              (t) => OrderingTerm.asc(t.orden),
              (t) => OrderingTerm.asc(t.id),
            ]))
          .watch();

  Future<Articulo> getArticuloById(int id) =>
      (select(articulos)..where((t) => t.id.equals(id))).getSingle();

  /// Siguiente valor de `orden` disponible para un artículo nuevo del
  /// lote [loteId], de forma que siempre se agregue al final de la lista.
  Future<int> obtenerSiguienteOrden(int loteId) async {
    final query = selectOnly(articulos)
      ..addColumns([articulos.orden.max()])
      ..where(articulos.loteId.equals(loteId));
    final fila = await query.getSingleOrNull();
    final maximo = fila?.read(articulos.orden.max());
    return (maximo ?? -1) + 1;
  }

  Future<int> insertArticulo(ArticulosCompanion entry) =>
      into(articulos).insert(entry);

  Future<bool> updateArticulo(ArticulosCompanion entry) =>
      update(articulos).replace(entry);

  Future<int> deleteArticulo(int id) =>
      (delete(articulos)..where((t) => t.id.equals(id))).go();

  Future<int> deleteArticulosByLote(int loteId) =>
      (delete(articulos)..where((t) => t.loteId.equals(loteId))).go();

  /// Persiste un nuevo orden manual: [idsEnNuevoOrden] es la lista completa
  /// de ids del lote en el orden en que deben quedar (el primero será el
  /// `orden` 0, el siguiente 1, etc.).
  Future<void> reordenarArticulos(List<int> idsEnNuevoOrden) {
    return batch((b) {
      for (var i = 0; i < idsEnNuevoOrden.length; i++) {
        b.update(
          articulos,
          ArticulosCompanion(orden: Value(i)),
          where: (t) => t.id.equals(idsEnNuevoOrden[i]),
        );
      }
    });
  }
}
