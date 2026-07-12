import 'package:app_inventario/core/db/database.dart';
import 'package:app_inventario/core/session/lote_activo_controller.dart';
import 'package:app_inventario/data/repositories/articulos_repository.dart';
import 'package:app_inventario/data/repositories/campos_config_repository.dart';
import 'package:app_inventario/data/repositories/lotes_repository.dart';
import 'package:app_inventario/features/lotes/lotes_list_screen.dart';
import 'package:app_inventario/features/splash/splash_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _buildTestApp(AppDatabase db, {Duration duracion = Duration.zero}) {
  return MultiProvider(
    providers: [
      Provider<AppDatabase>.value(value: db),
      Provider<LotesRepository>(create: (_) => LotesRepository(db.lotesDao)),
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
    child: MaterialApp(home: SplashScreen(duracion: duracion)),
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

  testWidgets('muestra el logo, el nombre de la app y el crédito',
      (tester) async {
    await tester.pumpWidget(
      _buildTestApp(db, duracion: const Duration(seconds: 10)),
    );
    await tester.pump();

    expect(find.text('BAJAPRO'), findsOneWidget);
    expect(find.text('Viceroy Los Cabos'), findsOneWidget);
    expect(find.text('Created by Gustavo Peralta'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, colorMarcaBajapro);

    await _desmontar(tester);
  });

  testWidgets('tras la duración configurada navega al listado de lotes',
      (tester) async {
    await tester.pumpWidget(_buildTestApp(db));
    await tester.pump();
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(LotesListScreen), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);

    await _desmontar(tester);
  });
}
