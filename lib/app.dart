import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/db/database.dart';
import 'core/session/lote_activo_controller.dart';
import 'data/repositories/articulos_repository.dart';
import 'data/repositories/campos_config_repository.dart';
import 'data/repositories/lotes_repository.dart';
import 'features/lotes/lotes_list_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>(
          create: (_) => AppDatabase(),
          dispose: (_, db) => db.close(),
        ),
        Provider<LotesRepository>(
          create: (context) =>
              LotesRepository(context.read<AppDatabase>().lotesDao),
        ),
        Provider<ArticulosRepository>(
          create: (context) =>
              ArticulosRepository(context.read<AppDatabase>().articulosDao),
        ),
        Provider<CamposConfigRepository>(
          create: (context) => CamposConfigRepository(
            context.read<AppDatabase>().customFieldDefinitionsDao,
          ),
        ),
        ChangeNotifierProvider<LoteActivoController>(
          create: (_) => LoteActivoController(),
        ),
      ],
      child: MaterialApp(
        title: 'AppInventario',
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: const LotesListScreen(),
      ),
    );
  }
}
