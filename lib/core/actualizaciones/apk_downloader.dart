import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

Future<http.StreamedResponse> _obtenerStreamReal(Uri uri) =>
    http.Client().send(http.Request('GET', uri));

/// Descarga el APK de [url] a un archivo temporal (mismo nombre siempre:
/// cada descarga sobrescribe la anterior), reportando el progreso
/// (0.0 a 1.0; `null` si el servidor no informa el tamaño total) via
/// [onProgreso]. Devuelve la ruta local del archivo ya descargado.
Future<String> descargarApk(
  String url,
  void Function(double? progreso) onProgreso, {
  Future<http.StreamedResponse> Function(Uri uri) obtenerStream =
      _obtenerStreamReal,
  Future<Directory> Function() obtenerDirectorio = getTemporaryDirectory,
}) async {
  final respuesta = await obtenerStream(Uri.parse(url));
  final directorio = await obtenerDirectorio();
  final archivo = File('${directorio.path}/bajapro_actualizacion.apk');
  final sink = archivo.openWrite();

  final total = respuesta.contentLength;
  var recibidos = 0;
  await for (final chunk in respuesta.stream) {
    sink.add(chunk);
    recibidos += chunk.length;
    onProgreso(total != null && total > 0 ? recibidos / total : null);
  }
  await sink.close();

  return archivo.path;
}

/// Abre el instalador nativo de Android para el APK ya descargado en
/// [rutaArchivo]. Android siempre exige una confirmación del usuario para
/// instalar (no hay forma de saltarla sin un dispositivo administrado por
/// MDM); esto solo evita el paso de descargar por el navegador.
Future<OpenResult> instalarApk(String rutaArchivo) => OpenFile.open(
      rutaArchivo,
      type: 'application/vnd.android.package-archive',
    );
