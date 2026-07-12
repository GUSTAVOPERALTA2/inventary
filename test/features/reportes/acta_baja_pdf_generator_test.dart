import 'dart:convert';
import 'dart:io';

import 'package:app_inventario/core/db/database.dart';
import 'package:app_inventario/features/reportes/acta_baja_pdf_generator.dart';
import 'package:flutter_test/flutter_test.dart';

Articulo _articulo({required int id, String? fotoPath, String? descripcion}) {
  return Articulo(
    id: id,
    loteId: 1,
    noSerie: 'SN-$id',
    descripcion: descripcion ?? 'Articulo $id',
    cantidad: 2,
    unidadMedida: 'Pieza',
    precioUnitario: 100,
    fotoPath: fotoPath,
    customValues: const {},
    createdAt: DateTime(2026, 1, 1),
  );
}

/// Cuenta paginas fisicas contando los objetos "/Type /Page" (sin contar
/// "/Type /Pages", el nodo raiz del arbol de paginas).
int _contarPaginas(List<int> bytes) {
  final texto = String.fromCharCodes(bytes);
  return RegExp(r'/Type\s*/Page(?!s)').allMatches(texto).length;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final encabezado = EncabezadoActa(
    nombreLote: 'Lote de prueba',
    area: 'SEGURIDAD',
    departamento: 'ADMINISTRACION',
    fecha: DateTime(2026, 4, 7),
    hora: '15:00',
  );

  test('genera bytes de un PDF valido para una hoja de 5 articulos', () async {
    final articulos = List.generate(5, (i) => _articulo(id: i + 1));

    final bytes = await generarActaBajaPdf(
      articulos: articulos,
      encabezado: encabezado,
    );

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('12 articulos no truenan y producen mas bytes que una sola hoja',
      () async {
    final unaHoja = await generarActaBajaPdf(
      articulos: List.generate(5, (i) => _articulo(id: i + 1)),
      encabezado: encabezado,
    );
    final tresHojas = await generarActaBajaPdf(
      articulos: List.generate(12, (i) => _articulo(id: i + 1)),
      encabezado: encabezado,
    );

    expect(tresHojas.length, greaterThan(unaHoja.length));
  });

  test('incluye la foto de un articulo cuando el archivo existe', () async {
    final tempDir = await Directory.systemTemp.createTemp('acta_pdf_test');
    final foto = File('${tempDir.path}/foto.png');
    // 1x1 PNG minimo valido.
    await foto.writeAsBytes(base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    ));

    final bytes = await generarActaBajaPdf(
      articulos: [_articulo(id: 1, fotoPath: foto.path)],
      encabezado: encabezado,
    );

    expect(bytes, isNotEmpty);

    await tempDir.delete(recursive: true);
  });

  test(
      'una descripcion muy larga no pierde la seccion de firmas: '
      'genera una pagina extra en vez de recortar', () async {
    final descripcionLarga = List.generate(80, (_) => 'palabra').join(' ');
    final articulos = List.generate(
      5,
      (i) => _articulo(id: i + 1, descripcion: descripcionLarga),
    );

    final normal = await generarActaBajaPdf(
      articulos: List.generate(5, (i) => _articulo(id: i + 1)),
      encabezado: encabezado,
    );
    final conDescripcionLarga = await generarActaBajaPdf(
      articulos: articulos,
      encabezado: encabezado,
    );

    expect(_contarPaginas(normal), 1);
    expect(_contarPaginas(conDescripcionLarga), greaterThan(1));
  });

  test('no truena cuando no hay articulos (ninguna hoja)', () async {
    final bytes = await generarActaBajaPdf(
      articulos: const [],
      encabezado: encabezado,
    );
    expect(bytes, isNotEmpty); // el pdf resultante es valido aunque sin paginas de datos
  });

  group('imagenesSeparadas', () {
    final encabezadoSeparado = EncabezadoActa(
      nombreLote: 'Lote de prueba',
      area: 'SEGURIDAD',
      departamento: 'ADMINISTRACION',
      fecha: DateTime(2026, 4, 7),
      hora: '15:00',
      imagenesSeparadas: true,
    );

    test('una hoja de 5 articulos genera 2 paginas (datos + fotos)',
        () async {
      final articulos = List.generate(5, (i) => _articulo(id: i + 1));

      final sinSeparar = await generarActaBajaPdf(
        articulos: articulos,
        encabezado: encabezado,
      );
      final separadas = await generarActaBajaPdf(
        articulos: articulos,
        encabezado: encabezadoSeparado,
      );

      expect(_contarPaginas(sinSeparar), 1);
      expect(_contarPaginas(separadas), 2);
    });

    test('12 articulos (3 hojas de datos) generan 6 paginas en total',
        () async {
      final articulos = List.generate(12, (i) => _articulo(id: i + 1));

      final separadas = await generarActaBajaPdf(
        articulos: articulos,
        encabezado: encabezadoSeparado,
      );

      expect(_contarPaginas(separadas), 6);
    });

    test('incluye la foto de un articulo en su propia hoja de fotos',
        () async {
      final tempDir = await Directory.systemTemp.createTemp('acta_pdf_test');
      final foto = File('${tempDir.path}/foto.png');
      await foto.writeAsBytes(base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
      ));

      final bytes = await generarActaBajaPdf(
        articulos: [_articulo(id: 1, fotoPath: foto.path)],
        encabezado: encabezadoSeparado,
      );

      expect(bytes, isNotEmpty);
      expect(_contarPaginas(bytes), 2);

      await tempDir.delete(recursive: true);
    });
  });
}
