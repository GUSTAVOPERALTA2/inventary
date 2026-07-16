import 'dart:io';

import 'package:app_inventario/core/actualizaciones/apk_downloader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  late Directory tempDir;

  setUp(() => tempDir = Directory.systemTemp.createTempSync('apk_downloader_test'));
  tearDown(() => tempDir.deleteSync(recursive: true));

  test('descarga el archivo completo y reporta progreso 0-1 cuando el '
      'servidor informa el tamaño total', () async {
    final contenido = List.generate(100, (i) => i % 256);
    final progresos = <double?>[];

    final ruta = await descargarApk(
      'http://servidor-de-prueba/app.apk',
      (p) => progresos.add(p),
      obtenerStream: (uri) async => http.StreamedResponse(
        Stream.fromIterable([contenido.sublist(0, 50), contenido.sublist(50)]),
        200,
        contentLength: contenido.length,
      ),
      obtenerDirectorio: () async => tempDir,
    );

    final archivo = File(ruta);
    expect(archivo.existsSync(), isTrue);
    expect(archivo.readAsBytesSync(), contenido);
    expect(progresos, [0.5, 1.0]);
  });

  test('reporta progreso null cuando el servidor no informa el tamaño total',
      () async {
    final progresos = <double?>[];

    await descargarApk(
      'http://servidor-de-prueba/app.apk',
      (p) => progresos.add(p),
      obtenerStream: (uri) async => http.StreamedResponse(
        Stream.fromIterable([
          [1, 2, 3],
        ]),
        200,
      ),
      obtenerDirectorio: () async => tempDir,
    );

    expect(progresos, [null]);
  });

  test('descargas sucesivas sobrescriben el mismo archivo', () async {
    Future<String> descargarConContenido(List<int> bytes) => descargarApk(
          'http://servidor-de-prueba/app.apk',
          (_) {},
          obtenerStream: (uri) async => http.StreamedResponse(
            Stream.fromIterable([bytes]),
            200,
            contentLength: bytes.length,
          ),
          obtenerDirectorio: () async => tempDir,
        );

    final ruta1 = await descargarConContenido([1, 1, 1]);
    final ruta2 = await descargarConContenido([2, 2]);

    expect(ruta1, ruta2);
    expect(File(ruta2).readAsBytesSync(), [2, 2]);
  });
}
