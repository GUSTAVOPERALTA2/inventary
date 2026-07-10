import 'package:app_inventario/core/db/database.dart';
import 'package:app_inventario/data/models/campo_tipo.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('crear un lote lo hace aparecer en watchAllLotes', () async {
    final id =
        await db.lotesDao.insertLote(LotesCompanion.insert(nombre: 'Lote 1'));

    final lotes = await db.lotesDao.watchAllLotes().first;

    expect(lotes, hasLength(1));
    expect(lotes.single.id, id);
    expect(lotes.single.nombre, 'Lote 1');
  });

  test('un articulo con cantidad fraccionaria y custom_values hace round-trip integro',
      () async {
    final loteId =
        await db.lotesDao.insertLote(LotesCompanion.insert(nombre: 'Lote 2'));

    final articuloId = await db.articulosDao.insertArticulo(
      ArticulosCompanion.insert(
        loteId: loteId,
        noSerie: 'SN-001',
        descripcion: 'Laptop',
        cantidad: 2.5,
        customValues: {
          'color': 'gris',
          'marca': 'Dell',
          'garantia_meses': 12,
        },
      ),
    );

    final articulo = await db.articulosDao.getArticuloById(articuloId);

    expect(articulo.cantidad, 2.5);
    expect(articulo.customValues, {
      'color': 'gris',
      'marca': 'Dell',
      'garantia_meses': 12,
    });
  });

  test(
      'el borrado logico de una definicion de campo no afecta el historico de un articulo',
      () async {
    final defId = await db.customFieldDefinitionsDao.insertDefinition(
      CustomFieldDefinitionsCompanion.insert(
        nombre: 'color',
        tipo: CampoTipo.texto,
        orden: 1,
      ),
    );

    final loteId =
        await db.lotesDao.insertLote(LotesCompanion.insert(nombre: 'Lote 3'));
    await db.articulosDao.insertArticulo(
      ArticulosCompanion.insert(
        loteId: loteId,
        noSerie: 'SN-002',
        descripcion: 'Monitor',
        cantidad: 1,
        customValues: {'color': 'negro'},
      ),
    );

    await db.customFieldDefinitionsDao.softDeleteDefinition(defId);

    final activas =
        await db.customFieldDefinitionsDao.watchActiveDefinitions().first;
    final todas =
        await db.customFieldDefinitionsDao.watchAllDefinitions().first;
    expect(activas, isEmpty);
    expect(todas, hasLength(1));
    expect(todas.single.activo, isFalse);

    final articulos =
        await db.articulosDao.watchArticulosByLote(loteId).first;
    expect(articulos.single.customValues['color'], 'negro');
  });
}
