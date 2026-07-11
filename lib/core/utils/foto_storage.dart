import 'dart:io';

import 'package:path/path.dart' as p;

/// Nombre de la subcarpeta, dentro del directorio de documentos de la app,
/// donde viven las fotos de los articulos.
const String carpetaFotosArticulos = 'fotos_articulos';

/// Contador que se suma al timestamp para garantizar nombres únicos aunque
/// el reloj no tenga resolución de microsegundos real (pasa en Windows) y
/// dos fotos se guarden en el mismo tick.
int _contadorNombres = 0;

/// Copia la foto tomada (en [origenPath], típicamente una ruta temporal que
/// entrega la cámara) a un archivo persistente dentro de [directorioBase]
/// (el directorio de documentos de la app) y devuelve la ruta final para
/// guardar en `articulos.foto_path`.
///
/// Recibe el directorio base por parámetro (en vez de resolverlo con
/// path_provider aquí mismo) para que esta función sea pura y testeable sin
/// necesitar un plugin nativo.
Future<String> guardarFotoArticulo({
  required String origenPath,
  required Directory directorioBase,
}) async {
  final carpetaDestino = Directory(
    p.join(directorioBase.path, carpetaFotosArticulos),
  );
  await carpetaDestino.create(recursive: true);

  final nombreArchivo = '${DateTime.now().microsecondsSinceEpoch}_'
      '${_contadorNombres++}${p.extension(origenPath)}';
  final destino = p.join(carpetaDestino.path, nombreArchivo);

  await File(origenPath).copy(destino);
  return destino;
}
