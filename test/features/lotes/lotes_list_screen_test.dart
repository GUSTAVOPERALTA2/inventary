import 'package:app_inventario/core/db/database.dart';
import 'package:app_inventario/core/session/lote_activo_controller.dart';
import 'package:app_inventario/data/repositories/articulos_repository.dart';
import 'package:app_inventario/data/repositories/campos_config_repository.dart';
import 'package:app_inventario/data/repositories/lotes_repository.dart';
import 'package:app_inventario/features/articulos/articulos_list_screen.dart';
import 'package:app_inventario/features/lotes/lotes_list_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _buildTestApp(AppDatabase db) {
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
      ChangeNotifierProvider<LoteActivoController>(
        create: (_) => LoteActivoController(),
      ),
    ],
    child: const MaterialApp(home: LotesListScreen()),
  );
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

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  });
}
