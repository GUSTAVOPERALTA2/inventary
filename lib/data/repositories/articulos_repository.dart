import 'package:drift/drift.dart';

import '../../core/db/daos/articulos_dao.dart';
import '../../core/db/database.dart';

class ArticulosRepository {
  ArticulosRepository(this._dao);

  final ArticulosDao _dao;

  Stream<List<Articulo>> watchArticulosByLote(int loteId) =>
      _dao.watchArticulosByLote(loteId);

  Future<Articulo> getArticuloById(int id) => _dao.getArticuloById(id);

  Future<int> crearArticulo({
    required int loteId,
    required String noSerie,
    required String descripcion,
    required double cantidad,
    required String unidadMedida,
    required double precioUnitario,
    String? fotoPath,
    Map<String, dynamic> customValues = const {},
  }) =>
      _dao.insertArticulo(ArticulosCompanion.insert(
        loteId: loteId,
        noSerie: noSerie,
        descripcion: descripcion,
        cantidad: cantidad,
        unidadMedida: Value(unidadMedida),
        precioUnitario: Value(precioUnitario),
        fotoPath: Value(fotoPath),
        customValues: customValues,
      ));

  // nullToAbsent=false: si fotoPath queda en null (se quitó la foto), debe
  // escribirse como NULL en la fila, no quedar "ausente" (lo que dejaría el
  // valor anterior intacto en la base de datos).
  Future<bool> actualizarArticulo(Articulo articulo) =>
      _dao.updateArticulo(articulo.toCompanion(false));

  Future<int> eliminarArticulo(int id) => _dao.deleteArticulo(id);
}
