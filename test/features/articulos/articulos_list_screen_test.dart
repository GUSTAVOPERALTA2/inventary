import 'dart:io';

import 'package:app_inventario/core/db/database.dart';
import 'package:app_inventario/data/repositories/articulos_repository.dart';
import 'package:app_inventario/data/repositories/campos_config_repository.dart';
import 'package:app_inventario/features/articulos/articulos_list_screen.dart';
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
  AppDatabase db,
  int loteId, {
  Directory? directorioFotos,
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
      home: ArticulosListScreen(
        loteId: loteId,
        nombreLote: 'Lote de prueba',
        obtenerDirectorioFotos:
            directorioFotos == null ? null : () async => directorioFotos,
      ),
    ),
  );
}

// Desmonta el arbol dentro de la zona de test para que Drift pueda cancelar
// el stream de la consulta sin dejar un timer pendiente (ver Bloque 2).
Future<void> _desmontar(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
}

/// El formulario ya no cabe en el tamaño de pantalla de prueba por defecto;
/// sin esto, el ListView no llega a construir los widgets fuera de la vista
/// (mas alla del cache extent) y los finders no los encuentran.
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
    tempDir =
        await Directory.systemTemp.createTemp('articulos_list_screen_test');
  });
  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('muestra el estado vacío cuando no hay artículos',
      (tester) async {
    await tester.pumpWidget(_buildTestApp(db, loteId));
    await tester.pumpAndSettle();

    expect(find.textContaining('Todavía no hay artículos'), findsOneWidget);

    await _desmontar(tester);
  });

  testWidgets('crear un artículo lo agrega a la lista', (tester) async {
    _agrandarViewport(tester);
    final directorioFotos = Directory('${tempDir.path}/documents')
      ..createSync();
    final fotoOrigen = File('${tempDir.path}/camera_capture.jpg')
      ..writeAsBytesSync([9, 9, 9]);
    ImagePickerPlatform.instance = _FakeImagePickerPlatform(fotoOrigen.path);

    await tester.pumpWidget(
      _buildTestApp(db, loteId, directorioFotos: directorioFotos),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'No. de serie'),
      'SN-100',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Descripción'),
      'Laptop Dell',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Cantidad'),
      '3',
    );
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pieza').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Precio unitario'),
      '150',
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

    expect(find.text('SN-100'), findsOneWidget);
    expect(find.textContaining('3 Pieza'), findsOneWidget);

    await _desmontar(tester);
  });

  testWidgets('editar un artículo actualiza la lista', (tester) async {
    _agrandarViewport(tester);
    final directorioFotos = Directory('${tempDir.path}/documents')
      ..createSync();
    final fotoExistente =
        File('${directorioFotos.path}/fotos_articulos/existente.jpg')
          ..createSync(recursive: true);
    fotoExistente.writeAsBytesSync([1]);

    await db.articulosDao.insertArticulo(ArticulosCompanion.insert(
      loteId: loteId,
      noSerie: 'SN-200',
      descripcion: 'Monitor',
      cantidad: 1,
      unidadMedida: const Value('Pieza'),
      precioUnitario: const Value(500),
      fotoPath: Value(fotoExistente.path),
      customValues: const {},
    ));

    await tester.pumpWidget(
      _buildTestApp(db, loteId, directorioFotos: directorioFotos),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('SN-200'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Descripción'),
      'Monitor 24 pulgadas',
    );
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Monitor 24 pulgadas'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);

    await _desmontar(tester);
  });

  testWidgets('eliminar un artículo lo quita de la lista tras confirmar',
      (tester) async {
    await db.articulosDao.insertArticulo(ArticulosCompanion.insert(
      loteId: loteId,
      noSerie: 'SN-300',
      descripcion: 'Teclado',
      cantidad: 2,
      customValues: const {},
    ));

    await tester.pumpWidget(_buildTestApp(db, loteId));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    expect(find.text('SN-300'), findsNothing);

    await _desmontar(tester);
  });

  testWidgets(
      'arrastrar el icono de mover reordena los artículos y persiste el orden',
      (tester) async {
    _agrandarViewport(tester);
    final id1 = await db.articulosDao.insertArticulo(ArticulosCompanion.insert(
      loteId: loteId,
      noSerie: 'SN-A',
      descripcion: 'Primero',
      cantidad: 1,
      customValues: const {},
      orden: const Value(0),
    ));
    final id2 = await db.articulosDao.insertArticulo(ArticulosCompanion.insert(
      loteId: loteId,
      noSerie: 'SN-B',
      descripcion: 'Segundo',
      cantidad: 1,
      customValues: const {},
      orden: const Value(1),
    ));
    final id3 = await db.articulosDao.insertArticulo(ArticulosCompanion.insert(
      loteId: loteId,
      noSerie: 'SN-C',
      descripcion: 'Tercero',
      cantidad: 1,
      customValues: const {},
      orden: const Value(2),
    ));

    await tester.pumpWidget(_buildTestApp(db, loteId));
    await tester.pumpAndSettle();

    // Confirma el orden inicial en pantalla (de arriba a abajo).
    expect(
      tester
          .getTopLeft(find.text('SN-A'))
          .dy
          .compareTo(tester.getTopLeft(find.text('SN-B')).dy),
      lessThan(0),
    );

    // Simular el gesto de arrastre real sobre ReorderableListView es frágil
    // en tests (usa un reconocedor de multi-drag propio, no un drag comun);
    // en vez de eso, se invoca directo el callback onReorderItem que la
    // propia app conecta — se confia en que el widget de Flutter dispara
    // ese callback correctamente, y se prueba la logica que escribimos
    // nosotros (_reordenar).
    final reorderableListView =
        tester.widget<ReorderableListView>(find.byType(ReorderableListView));
    reorderableListView.onReorderItem!(0, 2);
    // pumpAndSettle() se queda esperando indefinidamente aqui (mismo patron
    // ya visto al reordenar/eliminar lotes); un par de pumps acotados
    // alcanzan para reflejar el rebuild tras el reordenamiento.
    await tester.pump();
    await tester.pump();

    // Suscribirse recien aqui a un watch() nuevo, tras el reordenamiento,
    // tampoco resuelve sin runAsync (mismo patron que en lotes_list_screen_test).
    late List<Articulo> articulosFinal;
    await tester.runAsync(() async {
      articulosFinal = await db.articulosDao.watchArticulosByLote(loteId).first;
    });
    final idsFinal = articulosFinal.map((a) => a.id).toList();

    expect(idsFinal, [id2, id3, id1]);

    await _desmontar(tester);
  });
}
