import 'package:app_inventario/core/db/database.dart';
import 'package:app_inventario/data/models/campo_tipo.dart';
import 'package:drift/drift.dart' show Value;
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

  test('watchArticulosByLote respeta el orden manual, no el orden de creacion',
      () async {
    final loteId =
        await db.lotesDao.insertLote(LotesCompanion.insert(nombre: 'Lote 4'));

    // Se insertan en orden A, B, C pero con "orden" ya invertido.
    final idA = await db.articulosDao.insertArticulo(ArticulosCompanion.insert(
      loteId: loteId,
      noSerie: 'A',
      descripcion: 'A',
      cantidad: 1,
      customValues: const {},
      orden: const Value(2),
    ));
    final idB = await db.articulosDao.insertArticulo(ArticulosCompanion.insert(
      loteId: loteId,
      noSerie: 'B',
      descripcion: 'B',
      cantidad: 1,
      customValues: const {},
      orden: const Value(1),
    ));
    final idC = await db.articulosDao.insertArticulo(ArticulosCompanion.insert(
      loteId: loteId,
      noSerie: 'C',
      descripcion: 'C',
      cantidad: 1,
      customValues: const {},
      orden: const Value(0),
    ));

    final articulos =
        await db.articulosDao.watchArticulosByLote(loteId).first;

    expect(articulos.map((a) => a.id).toList(), [idC, idB, idA]);
  });

  test('reordenarArticulos persiste el nuevo orden', () async {
    final loteId =
        await db.lotesDao.insertLote(LotesCompanion.insert(nombre: 'Lote 5'));
    final id1 = await db.articulosDao.insertArticulo(ArticulosCompanion.insert(
      loteId: loteId,
      noSerie: '1',
      descripcion: '1',
      cantidad: 1,
      customValues: const {},
      orden: const Value(0),
    ));
    final id2 = await db.articulosDao.insertArticulo(ArticulosCompanion.insert(
      loteId: loteId,
      noSerie: '2',
      descripcion: '2',
      cantidad: 1,
      customValues: const {},
      orden: const Value(1),
    ));
    final id3 = await db.articulosDao.insertArticulo(ArticulosCompanion.insert(
      loteId: loteId,
      noSerie: '3',
      descripcion: '3',
      cantidad: 1,
      customValues: const {},
      orden: const Value(2),
    ));

    // Mover el ultimo (id3) al principio.
    await db.articulosDao.reordenarArticulos([id3, id1, id2]);

    final articulos =
        await db.articulosDao.watchArticulosByLote(loteId).first;
    expect(articulos.map((a) => a.id).toList(), [id3, id1, id2]);
  });

  test('obtenerSiguienteOrden devuelve 0 para un lote vacio y sigue la '
      'secuencia segun se van agregando articulos', () async {
    final loteId =
        await db.lotesDao.insertLote(LotesCompanion.insert(nombre: 'Lote 6'));

    expect(await db.articulosDao.obtenerSiguienteOrden(loteId), 0);

    await db.articulosDao.insertArticulo(ArticulosCompanion.insert(
      loteId: loteId,
      noSerie: '1',
      descripcion: '1',
      cantidad: 1,
      customValues: const {},
      orden: const Value(0),
    ));
    expect(await db.articulosDao.obtenerSiguienteOrden(loteId), 1);

    await db.articulosDao.insertArticulo(ArticulosCompanion.insert(
      loteId: loteId,
      noSerie: '2',
      descripcion: '2',
      cantidad: 1,
      customValues: const {},
      orden: const Value(1),
    ));
    expect(await db.articulosDao.obtenerSiguienteOrden(loteId), 2);
  });
}
