import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/actualizaciones/dialogo_actualizacion.dart';
import 'core/actualizaciones/version_checker.dart';
import 'core/db/database.dart';
import 'core/session/lote_activo_controller.dart';
import 'data/repositories/articulos_repository.dart';
import 'data/repositories/campos_config_repository.dart';
import 'data/repositories/lotes_repository.dart';
import 'features/splash/splash_screen.dart';

/// Dirección del servidor local de actualizaciones (ver `server/README.md`).
const String _endpointVersion = 'http://172.16.130.10:4300/version';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Se retrasa a propósito para no competir con la navegación automática
    // de la pantalla de inicio (2s): si hay actualización, el diálogo
    // aparece ya sobre el listado de lotes, nunca sobre el splash. Es
    // enteramente best-effort: sin wifi, con el servidor apagado o
    // inalcanzable, simplemente no pasa nada y la app sigue offline como
    // siempre.
    Future.delayed(const Duration(seconds: 4), _revisarActualizacion);
  }

  Future<void> _revisarActualizacion() async {
    final info = await buscarActualizacionDisponible(
      endpoint: Uri.parse(_endpointVersion),
    );
    if (info == null) return;
    final context = _navigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    await mostrarDialogoActualizacion(context, info);
  }

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
        navigatorKey: _navigatorKey,
        title: 'BAJAPRO',
        theme: ThemeData(colorSchemeSeed: colorMarcaBajapro, useMaterial3: true),
        home: const SplashScreen(),
      ),
    );
  }
}
