import 'package:app_inventario/core/db/database.dart';
import 'package:app_inventario/data/models/campo_tipo.dart';
import 'package:app_inventario/data/repositories/articulos_repository.dart';
import 'package:app_inventario/data/repositories/campos_config_repository.dart';
import 'package:app_inventario/features/articulos/articulo_form_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _buildTestApp(
  AppDatabase db, {
  required int loteId,
  Articulo? articulo,
}) {
  return MultiProvider(
    providers: [
      Provider<AppDatabase>.value(value: db),
      Provider<ArticulosRepository>(
        create: (_) => ArticulosRepository(db.articulosDao),
      ),
      Provider<CamposConfigRepository>(
        create: (_) => CamposConfigRepository(db.customFieldDefinitionsDao),
      ),
    ],
    child: MaterialApp(
      home: ArticuloFormScreen(loteId: loteId, articulo: articulo),
    ),
  );
}

Future<void> _desmontar(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
}

/// El formulario ya no cabe en el tamaño de pantalla de prueba por defecto;
/// sin esto, el ListView no llega a construir los widgets fuera de la
/// vista (mas alla del cache extent) y los finders no los encuentran.
void _agrandarViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  late AppDatabase db;
  late int loteId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    loteId = await db.lotesDao
        .insertLote(LotesCompanion.insert(nombre: 'Lote de prueba'));
  });
  tearDown(() => db.close());

  testWidgets(
      'un campo configurable activo aparece en el formulario y se guarda en custom_values',
      (tester) async {
    _agrandarViewport(tester);
    final campoId = await db.customFieldDefinitionsDao.insertDefinition(
      CustomFieldDefinitionsCompanion.insert(
        nombre: 'Color',
        tipo: CampoTipo.texto,
        orden: 0,
      ),
    );

    await tester.pumpWidget(_buildTestApp(db, loteId: loteId));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, 'Color'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'No. de serie'),
      'SN-500',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Descripción'),
      'Silla',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Cantidad'),
      '1',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Unidad de medida'),
      'Pieza',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Precio unitario'),
      '10',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Color'),
      'Rojo',
    );

    await tester.tap(find.text('Crear artículo'));
    await tester.pumpAndSettle();

    final articulos = await db.articulosDao.getArticuloById(1);
    expect(articulos.customValues[campoId.toString()], 'Rojo');

    await _desmontar(tester);
  });

  testWidgets(
      'un campo desactivado no aparece en el formulario pero su valor histórico sobrevive a una edición',
      (tester) async {
    _agrandarViewport(tester);
    final campoId = await db.customFieldDefinitionsDao.insertDefinition(
      CustomFieldDefinitionsCompanion.insert(
        nombre: 'Color',
        tipo: CampoTipo.texto,
        orden: 0,
      ),
    );
    final articuloId = await db.articulosDao.insertArticulo(
      ArticulosCompanion.insert(
        loteId: loteId,
        noSerie: 'SN-600',
        descripcion: 'Mesa',
        cantidad: 1,
        unidadMedida: const Value('Pieza'),
        precioUnitario: const Value(200),
        customValues: {campoId.toString(): 'Azul'},
      ),
    );
    await db.customFieldDefinitionsDao.softDeleteDefinition(campoId);

    final articulo = await db.articulosDao.getArticuloById(articuloId);
    await tester.pumpWidget(
      _buildTestApp(db, loteId: loteId, articulo: articulo),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, 'Color'), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Descripción'),
      'Mesa de madera',
    );
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    final actualizado = await db.articulosDao.getArticuloById(articuloId);
    expect(actualizado.descripcion, 'Mesa de madera');
    expect(actualizado.customValues[campoId.toString()], 'Azul');

    await _desmontar(tester);
  });
}
