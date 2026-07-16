import 'package:app_inventario/core/actualizaciones/dialogo_actualizacion.dart';
import 'package:app_inventario/core/actualizaciones/version_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_file/open_file.dart';

void main() {
  const info = InfoVersionRemota(
    versionCode: 3,
    versionName: '1.2.0',
    apkUrl: 'http://192.168.1.100:4300/descargas/app-release.apk',
    notas: 'Corrige un bug',
  );

  Widget buildTestApp(VoidCallback onPressed) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => FilledButton(
            onPressed: onPressed,
            child: const Text('abrir'),
          ),
        ),
      ),
    );
  }

  testWidgets('muestra la version y las notas', (tester) async {
    await tester.pumpWidget(buildTestApp(() {}));
    final capturedContext = tester.element(find.text('abrir'));

    mostrarDialogoActualizacion(
      capturedContext,
      info,
      descargarApkFn: (url, onProgreso) async => '/ruta/fake.apk',
      instalarApkFn: (ruta) async => OpenResult(type: ResultType.done),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('1.2.0'), findsOneWidget);
    expect(find.textContaining('Corrige un bug'), findsOneWidget);
    expect(find.text('Más tarde'), findsOneWidget);
    expect(find.text('Descargar'), findsOneWidget);
  });

  testWidgets('"Más tarde" cierra el dialogo sin descargar nada',
      (tester) async {
    var seDescargo = false;
    await tester.pumpWidget(buildTestApp(() {}));
    final capturedContext = tester.element(find.text('abrir'));

    mostrarDialogoActualizacion(
      capturedContext,
      info,
      descargarApkFn: (url, onProgreso) async {
        seDescargo = true;
        return '/ruta/fake.apk';
      },
      instalarApkFn: (ruta) async => OpenResult(type: ResultType.done),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Más tarde'));
    await tester.pumpAndSettle();

    expect(find.text('Más tarde'), findsNothing);
    expect(seDescargo, isFalse);
  });

  testWidgets(
      '"Descargar" muestra progreso y, al terminar, instala y cierra el dialogo',
      (tester) async {
    var seInstalo = false;
    await tester.pumpWidget(buildTestApp(() {}));
    final capturedContext = tester.element(find.text('abrir'));

    mostrarDialogoActualizacion(
      capturedContext,
      info,
      descargarApkFn: (url, onProgreso) async {
        onProgreso(0.5);
        await Future<void>.delayed(Duration.zero);
        onProgreso(1.0);
        return '/ruta/fake.apk';
      },
      instalarApkFn: (ruta) async {
        seInstalo = true;
        expect(ruta, '/ruta/fake.apk');
        return OpenResult(type: ResultType.done);
      },
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Descargar'));
    await tester.pump();

    expect(find.textContaining('Descargando'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(seInstalo, isTrue);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('si la descarga falla, muestra error con opcion de reintentar',
      (tester) async {
    var intentos = 0;
    await tester.pumpWidget(buildTestApp(() {}));
    final capturedContext = tester.element(find.text('abrir'));

    mostrarDialogoActualizacion(
      capturedContext,
      info,
      descargarApkFn: (url, onProgreso) async {
        intentos++;
        throw Exception('sin conexion');
      },
      instalarApkFn: (ruta) async => OpenResult(type: ResultType.done),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Descargar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('No se pudo descargar'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('Cerrar'), findsOneWidget);
    expect(intentos, 1);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(intentos, 2);
  });

  testWidgets(
      'si el instalador reporta permiso denegado, explica como habilitarlo',
      (tester) async {
    await tester.pumpWidget(buildTestApp(() {}));
    final capturedContext = tester.element(find.text('abrir'));

    mostrarDialogoActualizacion(
      capturedContext,
      info,
      descargarApkFn: (url, onProgreso) async => '/ruta/fake.apk',
      instalarApkFn: (ruta) async => OpenResult(
        type: ResultType.permissionDenied,
        message: 'Permission denied',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Descargar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Instalar apps desconocidas'), findsOneWidget);
  });
}
