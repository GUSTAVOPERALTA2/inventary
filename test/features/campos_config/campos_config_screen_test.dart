import 'package:app_inventario/core/db/database.dart';
import 'package:app_inventario/data/models/campo_tipo.dart';
import 'package:app_inventario/data/repositories/campos_config_repository.dart';
import 'package:app_inventario/features/campos_config/campos_config_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _buildTestApp(AppDatabase db) {
  return MultiProvider(
    providers: [
      Provider<AppDatabase>.value(value: db),
      Provider<CamposConfigRepository>(
        create: (_) => CamposConfigRepository(db.customFieldDefinitionsDao),
      ),
    ],
    child: const MaterialApp(home: CamposConfigScreen()),
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

  testWidgets('muestra el estado vacío cuando no hay campos', (tester) async {
    await tester.pumpWidget(_buildTestApp(db));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Todavía no hay campos configurables'),
      findsOneWidget,
    );

    await _desmontar(tester);
  });

  testWidgets('crear un campo de tipo lista lo agrega con sus opciones',
      (tester) async {
    await tester.pumpWidget(_buildTestApp(db));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre del campo'),
      'Condición',
    );

    await tester.tap(find.byType(DropdownButtonFormField<CampoTipo>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lista').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Opciones (separadas por coma)'),
      'Nuevo, Usado, Dañado',
    );

    await tester.tap(find.text('Crear campo'));
    await tester.pumpAndSettle();

    expect(find.text('Condición'), findsOneWidget);
    expect(find.textContaining('Nuevo, Usado, Dañado'), findsOneWidget);

    await _desmontar(tester);
  });

  testWidgets(
      'eliminar un campo lo marca como eliminado en vez de borrarlo',
      (tester) async {
    await db.customFieldDefinitionsDao.insertDefinition(
      CustomFieldDefinitionsCompanion.insert(
        nombre: 'Color',
        tipo: CampoTipo.texto,
        orden: 0,
      ),
    );

    await tester.pumpWidget(_buildTestApp(db));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('eliminado'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsNothing);

    final activas = await db.customFieldDefinitionsDao.getActiveDefinitions();
    expect(activas, isEmpty);

    await _desmontar(tester);
  });
}
