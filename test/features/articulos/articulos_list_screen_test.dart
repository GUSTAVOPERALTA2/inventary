import 'package:app_inventario/core/db/database.dart';
import 'package:app_inventario/data/repositories/articulos_repository.dart';
import 'package:app_inventario/data/repositories/campos_config_repository.dart';
import 'package:app_inventario/features/articulos/articulos_list_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _buildTestApp(AppDatabase db, int loteId) {
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
      home: ArticulosListScreen(loteId: loteId, nombreLote: 'Lote de prueba'),
    ),
  );
}

// Desmonta el arbol dentro de la zona de test para que Drift pueda cancelar
// el stream de la consulta sin dejar un timer pendiente (ver Bloque 2).
Future<void> _desmontar(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
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

  testWidgets('muestra el estado vacío cuando no hay artículos',
      (tester) async {
    await tester.pumpWidget(_buildTestApp(db, loteId));
    await tester.pumpAndSettle();

    expect(find.textContaining('Todavía no hay artículos'), findsOneWidget);

    await _desmontar(tester);
  });

  testWidgets('crear un artículo lo agrega a la lista', (tester) async {
    await tester.pumpWidget(_buildTestApp(db, loteId));
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
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Unidad de medida'),
      'Pieza',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Precio unitario'),
      '150',
    );

    await tester.tap(find.text('Crear artículo'));
    await tester.pumpAndSettle();

    expect(find.text('SN-100'), findsOneWidget);
    expect(find.textContaining('3 Pieza'), findsOneWidget);

    await _desmontar(tester);
  });

  testWidgets('editar un artículo actualiza la lista', (tester) async {
    await db.articulosDao.insertArticulo(ArticulosCompanion.insert(
      loteId: loteId,
      noSerie: 'SN-200',
      descripcion: 'Monitor',
      cantidad: 1,
      unidadMedida: const Value('Pieza'),
      precioUnitario: const Value(500),
      customValues: const {},
    ));

    await tester.pumpWidget(_buildTestApp(db, loteId));
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
}
