import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/articulos_table.dart';

part 'articulos_dao.g.dart';

@DriftAccessor(tables: [Articulos])
class ArticulosDao extends DatabaseAccessor<AppDatabase>
    with _$ArticulosDaoMixin {
  ArticulosDao(super.db);

  Stream<List<Articulo>> watchArticulosByLote(int loteId) =>
      (select(articulos)..where((t) => t.loteId.equals(loteId))).watch();

  Future<Articulo> getArticuloById(int id) =>
      (select(articulos)..where((t) => t.id.equals(id))).getSingle();

  Future<int> insertArticulo(ArticulosCompanion entry) =>
      into(articulos).insert(entry);

  Future<bool> updateArticulo(ArticulosCompanion entry) =>
      update(articulos).replace(entry);

  Future<int> deleteArticulo(int id) =>
      (delete(articulos)..where((t) => t.id.equals(id))).go();
}
