import 'dart:io';

import 'package:app_inventario/core/db/database.dart';
import 'package:app_inventario/core/session/lote_activo_controller.dart';
import 'package:app_inventario/data/repositories/articulos_repository.dart';
import 'package:app_inventario/data/repositories/campos_config_repository.dart';
import 'package:app_inventario/data/repositories/lotes_repository.dart';
import 'package:app_inventario/features/articulos/articulos_list_screen.dart';
import 'package:app_inventario/features/lotes/lotes_list_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _buildTestApp(
  AppDatabase db, {
  LoteActivoController? loteActivoController,
}) {
  final controller = loteActivoController ?? LoteActivoController();
  return MultiProvider(
    providers: [
      Provider<AppDatabase>.value(value: db),
      Provider<LotesRepository>(
        create: (_) => LotesRepository(db.lotesDao),
      ),
      Provider<ArticulosRepository>(
        create: (_) => ArticulosRepository(db.articulosDao),
      ),
      Provider<CamposConfigRepository>(
        create: (_) => CamposConfigRepository(db.customFieldDefinitionsDao),
      ),
      ChangeNotifierProvider<LoteActivoController>.value(value: controller),
    ],
    child: const MaterialApp(home: LotesListScreen()),
  );
}

Future<void> _desmontar(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  testWidgets('muestra el estado vacío cuando no hay lotes', (tester) async {
    await tester.pumpWidget(_buildTestApp(db));
    await tester.pumpAndSettle();

    expect(
      find.text('Todavía no hay lotes. Crea el primero con el botón +.'),
      findsOneWidget,
    );

    // Desmonta el arbol dentro de la zona de test para que Drift pueda
    // cancelar el stream de la consulta sin dejar un timer pendiente.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  });

  testWidgets('crear un lote lo agrega a la lista y se puede seleccionar',
      (tester) async {
    await tester.pumpWidget(_buildTestApp(db));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Lote de prueba');
    await tester.tap(find.text('Crear'));
    await tester.pumpAndSettle();

    expect(find.text('Lote de prueba'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsNothing);

    await tester.tap(find.text('Lote de prueba'));
    await tester.pumpAndSettle();

    // Seleccionar un lote navega a su pantalla de artículos; volvemos para
    // verificar que haya quedado marcado como activo en la lista de lotes.
    expect(find.byType(ArticulosListScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    await _desmontar(tester);
  });

  testWidgets('renombrar un lote actualiza el nombre en la lista',
      (tester) async {
    await db.lotesDao.insertLote(LotesCompanion.insert(nombre: 'Lote viejo'));

    await tester.pumpWidget(_buildTestApp(db));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Lote renombrado');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Lote renombrado'), findsOneWidget);
    expect(find.text('Lote viejo'), findsNothing);

    await _desmontar(tester);
  });

  testWidgets('cancelar el renombrado no cambia el nombre', (tester) async {
    await db.lotesDao.insertLote(LotesCompanion.insert(nombre: 'Lote viejo'));

    await tester.pumpWidget(_buildTestApp(db));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Lote renombrado');
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.text('Lote viejo'), findsOneWidget);
    expect(find.text('Lote renombrado'), findsNothing);

    await _desmontar(tester);
  });

  testWidgets(
      'eliminar un lote borra sus articulos, sus fotos, y lo quita de la lista',
      (tester) async {
    // createTempSync/deleteSync (no las variantes async): dart:io async
    // llamado directo en el cuerpo de un testWidgets nunca resuelve dentro
    // de la zona FakeAsync y deja el test colgado indefinidamente.
    final tempDir = Directory.systemTemp.createTempSync('lotes_delete_test');
    final foto = File('${tempDir.path}/foto.jpg')
      ..writeAsBytesSync([1, 2, 3]);

    final loteId = await db.lotesDao
        .insertLote(LotesCompanion.insert(nombre: 'Lote a borrar'));
    await db.articulosDao.insertArticulo(ArticulosCompanion.insert(
      loteId: loteId,
      noSerie: 'SN-1',
      descripcion: 'Articulo',
      cantidad: 1,
      fotoPath: Value(foto.path),
      customValues: const {},
    ));

    final loteActivoController = LoteActivoController()..seleccionar(loteId);

    await tester.pumpWidget(
      _buildTestApp(db, loteActivoController: loteActivoController),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    // El manejador consulta articulosRepo antes de mostrar el dialogo, y el
    // borrado hace E/S real (archivo.exists()/archivo.delete()); sin
    // runAsync, ese trabajo nunca completa dentro de la zona FakeAsync.
    await tester.runAsync(() async {
      await tester.tap(find.byIcon(Icons.delete_outline));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    expect(find.textContaining('1 artículo(s)'), findsOneWidget);

    await tester.runAsync(() async {
      await tester.tap(find.text('Eliminar'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    // pumpAndSettle() se queda esperando indefinidamente aqui (no llega a
    // asentarse); un par de pumps acotados alcanzan para reflejar el
    // rebuild de la lista tras el borrado.
    await tester.pump();
    await tester.pump();

    expect(find.text('Lote a borrar'), findsNothing);
    // Igual que el borrado en si: suscribirse recien aqui a un watch()
    // (aunque sea de solo lectura) tras el runAsync anterior no resuelve
    // sin envolverlo tambien en runAsync.
    late List<Articulo> articulosRestantes;
    await tester.runAsync(() async {
      articulosRestantes =
          await db.articulosDao.watchArticulosByLote(loteId).first;
    });
    expect(articulosRestantes, isEmpty);
    expect(foto.existsSync(), isFalse);
    expect(loteActivoController.value, isNull);

    tempDir.deleteSync(recursive: true);
    await _desmontar(tester);
  });

  testWidgets('cancelar la eliminacion conserva el lote y sus articulos',
      (tester) async {
    final loteId = await db.lotesDao
        .insertLote(LotesCompanion.insert(nombre: 'Lote a conservar'));
    await db.articulosDao.insertArticulo(ArticulosCompanion.insert(
      loteId: loteId,
      noSerie: 'SN-2',
      descripcion: 'Articulo',
      cantidad: 1,
      customValues: const {},
    ));

    await tester.pumpWidget(_buildTestApp(db));
    await tester.pumpAndSettle();

    // El manejador consulta articulosRepo (E/S/stream real) antes de
    // mostrar el dialogo; sin runAsync no completa dentro de FakeAsync.
    await tester.runAsync(() async {
      await tester.tap(find.byIcon(Icons.delete_outline));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.text('Lote a conservar'), findsOneWidget);
    late List<Articulo> articulosRestantes;
    await tester.runAsync(() async {
      articulosRestantes =
          await db.articulosDao.watchArticulosByLote(loteId).first;
    });
    expect(articulosRestantes, hasLength(1));

    await _desmontar(tester);
  });
}
