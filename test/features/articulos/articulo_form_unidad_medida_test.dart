import 'package:app_inventario/core/db/database.dart';
import 'package:app_inventario/data/repositories/articulos_repository.dart';
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
      'elegir "Otro" habilita un campo de texto y esa unidad se guarda tal cual',
      (tester) async {
    _agrandarViewport(tester);
    await tester.pumpWidget(_buildTestApp(db, loteId: loteId));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, 'Especifica la unidad de medida'),
        findsNothing);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Otro').last);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, 'Especifica la unidad de medida'),
        findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'No. de serie'),
      'SN-900',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Descripción'),
      'Rollo de cable',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Cantidad'),
      '2',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Especifica la unidad de medida'),
      'Rollo',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Precio unitario'),
      '80',
    );

    await tester.ensureVisible(find.text('Crear artículo'));
    await tester.tap(find.text('Crear artículo'));
    await tester.pumpAndSettle();

    final guardado = await db.articulosDao.getArticuloById(1);
    expect(guardado.unidadMedida, 'Rollo');

    await _desmontar(tester);
  });

  testWidgets(
      'editar un articulo con unidad preestablecida la muestra ya seleccionada',
      (tester) async {
    _agrandarViewport(tester);
    final articuloId = await db.articulosDao.insertArticulo(
      ArticulosCompanion.insert(
        loteId: loteId,
        noSerie: 'SN-910',
        descripcion: 'Bulto de cemento',
        cantidad: 5,
        unidadMedida: const Value('Kg'),
        precioUnitario: const Value(30),
        customValues: const {},
      ),
    );
    final articulo = await db.articulosDao.getArticuloById(articuloId);

    await tester.pumpWidget(
      _buildTestApp(db, loteId: loteId, articulo: articulo),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kg'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Especifica la unidad de medida'),
        findsNothing);

    await _desmontar(tester);
  });

  testWidgets(
      'editar un articulo con unidad no preestablecida selecciona Otro y precarga el texto',
      (tester) async {
    _agrandarViewport(tester);
    final articuloId = await db.articulosDao.insertArticulo(
      ArticulosCompanion.insert(
        loteId: loteId,
        noSerie: 'SN-920',
        descripcion: 'Cable',
        cantidad: 1,
        unidadMedida: const Value('Rollo'),
        precioUnitario: const Value(80),
        customValues: const {},
      ),
    );
    final articulo = await db.articulosDao.getArticuloById(articuloId);

    await tester.pumpWidget(
      _buildTestApp(db, loteId: loteId, articulo: articulo),
    );
    await tester.pumpAndSettle();

    expect(find.text('Otro'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Especifica la unidad de medida'),
      findsOneWidget,
    );

    final campoTexto = tester.widget<TextFormField>(
      find.widgetWithText(TextFormField, 'Especifica la unidad de medida'),
    );
    expect(campoTexto.controller!.text, 'Rollo');

    await _desmontar(tester);
  });
}
