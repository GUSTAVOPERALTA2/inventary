import 'package:app_inventario/core/db/database.dart';
import 'package:app_inventario/data/models/campo_tipo.dart';
import 'package:app_inventario/features/reportes/lote_zip_calculos.dart';
import 'package:flutter_test/flutter_test.dart';

Articulo _articulo({
  int id = 1,
  String noSerie = 'SN-1',
  double cantidad = 1,
  double precioUnitario = 0,
  Map<String, dynamic> customValues = const {},
  String? fotoPath,
}) {
  return Articulo(
    id: id,
    loteId: 1,
    noSerie: noSerie,
    descripcion: 'Articulo $id',
    cantidad: cantidad,
    unidadMedida: 'Pieza',
    precioUnitario: precioUnitario,
    fotoPath: fotoPath,
    customValues: customValues,
    createdAt: DateTime(2026, 1, 1),
    orden: id,
  );
}

CustomFieldDefinition _definicion({
  required int id,
  required String nombre,
  required CampoTipo tipo,
  int orden = 0,
  bool activo = true,
}) {
  return CustomFieldDefinition(
    id: id,
    nombre: nombre,
    tipo: tipo,
    opciones: null,
    orden: orden,
    activo: activo,
  );
}

void main() {
  group('sanitizarNombreArchivo', () {
    test('reemplaza caracteres invalidos por guion bajo', () {
      expect(sanitizarNombreArchivo('Lote: Almacén/2026?'), 'Lote_ Almacén_2026_');
    });

    test('un texto vacio produce un nombre por defecto', () {
      expect(sanitizarNombreArchivo('   '), 'sin_nombre');
    });
  });

  group('nombreArchivoZipLote', () {
    test('arma el nombre con fecha y hora en el orden esperado', () {
      final nombre =
          nombreArchivoZipLote('Almacén Central', DateTime(2026, 4, 7, 15, 5, 9));
      expect(nombre, 'Lote_Almacén Central_20260407_150509.zip');
    });
  });

  group('nombreArchivoFotoZip', () {
    test('antepone el id del articulo al no. de serie', () {
      final articulo = _articulo(id: 7, noSerie: 'SN-100');
      expect(nombreArchivoFotoZip(articulo, '.jpg'), '7_SN-100.jpg');
    });
  });

  group('construirCsvArticulos', () {
    test('el encabezado incluye las columnas fijas y los campos configurables',
        () {
      final definiciones = [
        _definicion(id: 1, nombre: 'Color', tipo: CampoTipo.texto),
      ];
      final csv = construirCsvArticulos(const [], definiciones);
      final primeraLinea = csv.split('\r\n').first;
      expect(
        primeraLinea,
        'No. Serie,Descripcion,Cantidad,Unidad de medida,'
        'Precio unitario,Precio total,Color,Foto',
      );
    });

    test('una fila refleja los valores del articulo y el precio total', () {
      final articulo = _articulo(
        noSerie: 'SN-9',
        cantidad: 2,
        precioUnitario: 50,
      );
      final csv = construirCsvArticulos([articulo], const []);
      final filas = csv.split('\r\n');
      expect(filas[1], 'SN-9,Articulo 1,2,Pieza,\$50.00,\$100.00,Sin foto');
    });

    test('marca la foto como disponible cuando el articulo tiene fotoPath',
        () {
      final articulo = _articulo(fotoPath: '/tmp/foto.jpg');
      final csv = construirCsvArticulos([articulo], const []);
      expect(csv.split('\r\n')[1], contains('Ver carpeta fotos/'));
    });

    test('formatea un campo de tipo fecha como DD-MM-YYYY', () {
      final definiciones = [
        _definicion(id: 5, nombre: 'Fecha de compra', tipo: CampoTipo.fecha),
      ];
      final articulo = _articulo(
        customValues: {'5': DateTime(2026, 4, 7).toIso8601String()},
      );
      final csv = construirCsvArticulos([articulo], definiciones);
      expect(csv.split('\r\n')[1], contains('07-04-2026'));
    });

    test('un valor de campo ausente se muestra como celda vacia', () {
      final definiciones = [
        _definicion(id: 2, nombre: 'Observaciones', tipo: CampoTipo.texto),
      ];
      final articulo = _articulo();
      final csv = construirCsvArticulos([articulo], definiciones);
      expect(
        csv.split('\r\n')[1],
        'SN-1,Articulo 1,1,Pieza,\$0.00,\$0.00,,Sin foto',
      );
    });

    test('escapa comas y comillas dentro de un valor', () {
      final definiciones = [
        _definicion(id: 3, nombre: 'Nota', tipo: CampoTipo.texto),
      ];
      final articulo = _articulo(
        customValues: {'3': 'Con "comillas", y coma'},
      );
      final csv = construirCsvArticulos([articulo], definiciones);
      expect(
        csv.split('\r\n')[1],
        contains('"Con ""comillas"", y coma"'),
      );
    });
  });
}
