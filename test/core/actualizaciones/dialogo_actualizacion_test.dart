import 'package:app_inventario/core/actualizaciones/dialogo_actualizacion.dart';
import 'package:app_inventario/core/actualizaciones/version_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  const info = InfoVersionRemota(
    versionCode: 3,
    versionName: '1.2.0',
    apkUrl: 'http://192.168.1.100:4000/descargas/app-release.apk',
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
    late BuildContext capturedContext;
    await tester.pumpWidget(
      buildTestApp(() {}),
    );
    capturedContext = tester.element(find.text('abrir'));

    mostrarDialogoActualizacion(
      capturedContext,
      info,
      abrirUrl: (url, {mode = LaunchMode.platformDefault}) async => true,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('1.2.0'), findsOneWidget);
    expect(find.textContaining('Corrige un bug'), findsOneWidget);
    expect(find.text('Más tarde'), findsOneWidget);
    expect(find.text('Descargar'), findsOneWidget);
  });

  testWidgets('"Más tarde" cierra el dialogo sin abrir la URL',
      (tester) async {
    var seAbrioUrl = false;
    await tester.pumpWidget(buildTestApp(() {}));
    final capturedContext = tester.element(find.text('abrir'));

    mostrarDialogoActualizacion(
      capturedContext,
      info,
      abrirUrl: (url, {mode = LaunchMode.platformDefault}) async {
        seAbrioUrl = true;
        return true;
      },
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Más tarde'));
    await tester.pumpAndSettle();

    expect(find.text('Más tarde'), findsNothing);
    expect(seAbrioUrl, isFalse);
  });

  testWidgets('"Descargar" abre la URL del APK y cierra el dialogo',
      (tester) async {
    Uri? urlAbierta;
    await tester.pumpWidget(buildTestApp(() {}));
    final capturedContext = tester.element(find.text('abrir'));

    mostrarDialogoActualizacion(
      capturedContext,
      info,
      abrirUrl: (url, {mode = LaunchMode.platformDefault}) async {
        urlAbierta = url;
        return true;
      },
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Descargar'));
    await tester.pumpAndSettle();

    expect(find.text('Descargar'), findsNothing);
    expect(urlAbierta, Uri.parse(info.apkUrl));
  });
}
