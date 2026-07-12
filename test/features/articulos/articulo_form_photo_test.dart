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
  required Directory directorioFotos,
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
      home: ArticuloFormScreen(
        loteId: loteId,
        articulo: articulo,
        obtenerDirectorioFotos: () async => directorioFotos,
      ),
    ),
  );
}

Future<void> _desmontar(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
}

/// El formulario ya no cabe en el tamaño de pantalla de prueba por defecto;
/// sin esto, algunos botones quedan fuera del area visible y el tap no
/// llega a golpearlos (o el ListView ni siquiera construye ese widget).
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
  late Directory directorioFotos;
  late File fotoOrigen;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    loteId = await db.lotesDao
        .insertLote(LotesCompanion.insert(nombre: 'Lote de prueba'));
    tempDir = await Directory.systemTemp.createTemp('articulo_form_photo_test');
    directorioFotos = Directory('${tempDir.path}/documents')..createSync();
    fotoOrigen = File('${tempDir.path}/camera_capture.jpg')
      ..writeAsBytesSync([9, 9, 9]);
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('tomar una foto la guarda en disco y se persiste en el articulo',
      (tester) async {
    _agrandarViewport(tester);
    ImagePickerPlatform.instance = _FakeImagePickerPlatform(fotoOrigen.path);

    await tester.pumpWidget(
      _buildTestApp(db, loteId: loteId, directorioFotos: directorioFotos),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tomar foto'), findsOneWidget);
    expect(find.byType(Image), findsNothing);

    // El picker (fake) y la copia a disco son E/S real; sin runAsync,
    // testWidgets corre dentro de una zona FakeAsync donde ese trabajo
    // nunca llega a completarse.
    await tester.runAsync(() async {
      await tester.tap(find.text('Tomar foto'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    expect(find.text('Cambiar foto'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'No. de serie'),
      'SN-700',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Descripción'),
      'Silla',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Cantidad'),
      '1',
    );
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pieza').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Precio unitario'),
      '50',
    );
    await tester.ensureVisible(find.text('Crear artículo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crear artículo'));
    await tester.pumpAndSettle();

    final guardado = await db.articulosDao.getArticuloById(1);
    expect(guardado.fotoPath, isNotNull);
    expect(File(guardado.fotoPath!).existsSync(), isTrue);

    await _desmontar(tester);
  });

  testWidgets(
      'quitar la foto sin volver a tomar una bloquea el guardado '
      '(la fotografía es obligatoria)', (tester) async {
    _agrandarViewport(tester);
    final fotoGuardada =
        File('${directorioFotos.path}/fotos_articulos/existente.jpg')
          ..createSync(recursive: true);
    fotoGuardada.writeAsBytesSync([1]);

    final articuloId = await db.articulosDao.insertArticulo(
      ArticulosCompanion.insert(
        loteId: loteId,
        noSerie: 'SN-800',
        descripcion: 'Mesa',
        cantidad: 1,
        unidadMedida: const Value('Pieza'),
        precioUnitario: const Value(75),
        fotoPath: Value(fotoGuardada.path),
        customValues: const {},
      ),
    );
    final articulo = await db.articulosDao.getArticuloById(articuloId);

    await tester.pumpWidget(
      _buildTestApp(
        db,
        loteId: loteId,
        directorioFotos: directorioFotos,
        articulo: articulo,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cambiar foto'), findsOneWidget);

    await tester.tap(find.text('Quitar'));
    await tester.pumpAndSettle();

    expect(find.text('Tomar foto'), findsOneWidget);

    await tester.ensureVisible(find.text('Guardar cambios'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    // La validacion bloquea el guardado: el formulario sigue abierto,
    // muestra el error, y el registro en la base no cambia.
    expect(find.text('La fotografía es obligatoria'), findsOneWidget);
    expect(find.text('Guardar cambios'), findsOneWidget);

    final sinCambios = await db.articulosDao.getArticuloById(articuloId);
    expect(sinCambios.fotoPath, fotoGuardada.path);

    await _desmontar(tester);
  });
}
