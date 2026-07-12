import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import '../../core/db/database.dart';
import 'lote_zip_calculos.dart';

/// Nombre de la subcarpeta, dentro del directorio de documentos de la
/// app, donde se guardan los ZIP de respaldo generados.
const String carpetaZipLotes = 'zip_lotes';

/// Arma el ZIP de respaldo de un lote: el acta en PDF, un CSV con el
/// resumen de articulos y las fotos que todavia existan en disco.
Uint8List construirZipLote({
  required List<Articulo> articulos,
  required List<CustomFieldDefinition> definiciones,
  required Uint8List actaPdfBytes,
}) {
  final archivo = Archive();
  archivo.addFile(ArchiveFile.bytes('acta_baja.pdf', actaPdfBytes));

  final csv = construirCsvArticulos(articulos, definiciones);
  archivo.addFile(ArchiveFile.bytes('articulos.csv', utf8.encode(csv)));

  for (final articulo in articulos) {
    final fotoPath = articulo.fotoPath;
    if (fotoPath == null) continue;
    final archivoFoto = File(fotoPath);
    if (!archivoFoto.existsSync()) continue;
    final nombreFoto = nombreArchivoFotoZip(articulo, p.extension(fotoPath));
    archivo.addFile(
      ArchiveFile.bytes('fotos/$nombreFoto', archivoFoto.readAsBytesSync()),
    );
  }

  return ZipEncoder().encodeBytes(archivo);
}

/// Guarda el ZIP ya armado en el almacenamiento propio de la app (no
/// requiere permisos de almacenamiento), listo para compartirse desde
/// ahi con el selector nativo.
Future<String> guardarZipLote({
  required Uint8List zipBytes,
  required String nombreArchivo,
  required Directory directorioBase,
}) async {
  final carpetaDestino = Directory(
    p.join(directorioBase.path, carpetaZipLotes),
  );
  await carpetaDestino.create(recursive: true);

  final destino = File(p.join(carpetaDestino.path, nombreArchivo));
  await destino.writeAsBytes(zipBytes);
  return destino.path;
}
