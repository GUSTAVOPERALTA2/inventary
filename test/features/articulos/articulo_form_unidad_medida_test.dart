import 'dart:io';

import 'package:app_inventario/core/db/database.dart';
import 'package:app_inventario/data/repositories/articulos_repository.dart';
import 'package:app_inventario/features/articulos/articulo_form_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:provider/provider.dart';

/// Doble de prueba para no depender del plugin nativo de la cámara: entrega
/// siempre el mismo archivo (o null, simulando que el usuario canceló).
class _FakeImagePickerPlatform extends ImagePickerPlatform {
  _FakeImagePickerPlatform(this._rutaAEntregar);
  final String? _rutaAEntregar;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    return _rutaAEntregar == null ? null : XFile(_rutaAEntregar);
  }
}

Widget _buildTestApp(
  AppDatabase db, {
  required int loteId,
  Articulo? articulo,
  Directory? directorioFotos,
}) {
  return MultiProvider(
    providers: [
      Provider<AppDatabase>.value(value: db),
      Provider<ArticulosRepository>(
        create: (_) => ArticulosRepository(db.articulosDao),
      ),
    ],
    child: MaterialApp(
      home: ArticuloFormScreen(
        loteId: loteId,
        articulo: articulo,
        obtenerDirectorioFotos:
            directorioFotos == null ? null : () async => directorioFotos,
      ),
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
  late Directory tempDir;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    loteId = await db.lotesDao
        .insertLote(LotesCompanion.insert(nombre: 'Lote de prueba'));
    tempDir = await Directory.systemTemp.createTemp('unidad_medida_test');
  });
  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets(
      'elegir "Otro" habilita un campo de texto y esa unidad se guarda tal cual',
      (tester) async {
    _agrandarViewport(tester);
    final directorioFotos = Directory('${tempDir.path}/documents')
      ..createSync();
    final fotoOrigen = File('${tempDir.path}/camera_capture.jpg')
      ..writeAsBytesSync([9, 9, 9]);
    ImagePickerPlatform.instance = _FakeImagePickerPlatform(fotoOrigen.path);

    await tester.pumpWidget(
      _buildTestApp(db, loteId: loteId, directorioFotos: directorioFotos),
    );
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

    // El picker (fake) y la copia a disco son E/S real; sin runAsync,
    // testWidgets corre dentro de una zona FakeAsync donde ese trabajo
    // nunca llega a completarse.
    await tester.runAsync(() async {
      await tester.tap(find.text('Tomar foto'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    await tester.tap(find.text('Crear artículo'));
    await tester.pumpAndSettle();

    final guardado = await db.articulosDao.getArticuloById(1);
    expect(guardado.unidadMedida, 'Rollo');
    expect(guardado.fotoPath, isNotNull);

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
