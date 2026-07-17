import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_inventario/core/db/database.dart';
import 'package:app_inventario/features/reportes/lote_zip_exporter.dart';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';

Articulo _articulo({required int id, String? fotoPath}) {
  return Articulo(
    id: id,
    loteId: 1,
    noSerie: 'SN-$id',
    descripcion: 'Articulo $id',
    cantidad: 2,
    unidadMedida: 'Pieza',
    precioUnitario: 100,
    fotoPath: fotoPath,
    customValues: const {},
    createdAt: DateTime(2026, 1, 1),
    orden: id,
  );
}

final _pdfFalso = Uint8List.fromList(utf8.encode('%PDF-falso-para-test'));

void main() {
  group('construirZipLote', () {
    test('incluye el acta y el csv aunque no haya fotos', () {
      final zipBytes = construirZipLote(
        articulos: [_articulo(id: 1)],
        definiciones: const [],
        actaPdfBytes: _pdfFalso,
      );

      final archivo = ZipDecoder().decodeBytes(zipBytes);
      final nombres = archivo.files.map((f) => f.name).toSet();

      expect(nombres, {'acta_baja.pdf', 'articulos.csv'});
    });

    test('incluye la foto de un articulo cuando el archivo existe', () async {
      final tempDir = await Directory.systemTemp.createTemp('zip_export_test');
      final foto = File('${tempDir.path}/foto.jpg');
      await foto.writeAsBytes([1, 2, 3, 4]);

      final zipBytes = construirZipLote(
        articulos: [_articulo(id: 1, fotoPath: foto.path)],
        definiciones: const [],
        actaPdfBytes: _pdfFalso,
      );

      final archivo = ZipDecoder().decodeBytes(zipBytes);
      final archivoFoto = archivo.files
          .firstWhere((f) => f.name == 'fotos/1_SN-1.jpg');
      expect(archivoFoto.content, [1, 2, 3, 4]);

      await tempDir.delete(recursive: true);
    });

    test('ignora un fotoPath que ya no existe en disco', () {
      final zipBytes = construirZipLote(
        articulos: [_articulo(id: 1, fotoPath: '/ruta/inexistente.jpg')],
        definiciones: const [],
        actaPdfBytes: _pdfFalso,
      );

      final archivo = ZipDecoder().decodeBytes(zipBytes);
      expect(archivo.files.any((f) => f.name.startsWith('fotos/')), isFalse);
    });
  });

  group('guardarZipLote', () {
    test('escribe el zip dentro de la subcarpeta zip_lotes', () async {
      final tempDir = await Directory.systemTemp.createTemp('zip_save_test');

      final ruta = await guardarZipLote(
        zipBytes: Uint8List.fromList([9, 9, 9]),
        nombreArchivo: 'Lote_prueba.zip',
        directorioBase: tempDir,
      );

      expect(ruta, contains('zip_lotes'));
      expect(await File(ruta).readAsBytes(), [9, 9, 9]);

      await tempDir.delete(recursive: true);
    });
  });
}
