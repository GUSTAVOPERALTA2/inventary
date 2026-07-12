import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/db/database.dart';
import 'acta_baja_calculos.dart';

/// Datos del acta que no viven en el lote ni en los artículos: se piden al
/// momento de generar el reporte (ver Bloque 6, decisión con el usuario).
class EncabezadoActa {
  EncabezadoActa({
    required this.nombreLote,
    required this.area,
    required this.departamento,
    required this.fecha,
    required this.hora,
    this.imagenesSeparadas = false,
  });

  final String nombreLote;
  final String area;
  final String departamento;
  final DateTime fecha;
  final String hora;

  /// Si es true, las fotografias no se muestran junto a la tabla de cada
  /// hoja: cada hoja de datos va seguida de su propia hoja dedicada con las
  /// fotos a mayor tamaño (decision con el usuario).
  final bool imagenesSeparadas;

  String get fechaFormateada =>
      '${fecha.day.toString().padLeft(2, '0')}-'
      '${fecha.month.toString().padLeft(2, '0')}-'
      '${(fecha.year % 100).toString().padLeft(2, '0')}';
}

/// Genera el PDF del acta de baja de productos siguiendo el formato oficial:
/// 5 artículos por hoja, con su tabla, total, fotos numeradas 1-5 y firmas
/// completas en cada hoja (cada hoja es un acta independiente).
Future<Uint8List> generarActaBajaPdf({
  required List<Articulo> articulos,
  required EncabezadoActa encabezado,
}) async {
  // Las fuentes base del paquete pdf no traen acentos ni "ñ"; se empaqueta
  // Noto Sans para que el texto en español del acta se vea completo sin
  // depender de internet. Se usa en vez de Arial (fuente propietaria, no
  // distribuible dentro de la app) pero respetando los tamaños/negritas
  // pedidos por el usuario. La variante bold es una instancia estatica
  // (peso 700) generada a partir del variable font: sin un maestro bold
  // separado, FontWeight.bold no se veia realmente mas grueso.
  final fuente = pw.Font.ttf(
    await rootBundle.load('assets/fonts/NotoSans.ttf'),
  );
  final fuenteBold = pw.Font.ttf(
    await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
  );
  final logo = pw.MemoryImage(
    (await rootBundle.load('assets/images/viceroy_logo.png'))
        .buffer
        .asUint8List(),
  );
  final documento = pw.Document(
    theme: pw.ThemeData.withFont(base: fuente, bold: fuenteBold),
  );
  final paginas = paginarArticulosActa(articulos);

  for (final pagina in paginas) {
    documento.addPage(
      // MultiPage (a diferencia de Page) deja que el contenido que no cabe
      // en una sola hoja fisica continue automaticamente en otra en vez de
      // recortarse: una descripcion larga ya no empuja la seccion de firmas
      // fuera del PDF, sino que la manda a una hoja adicional.
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(24),
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        build: (context) => _construirHojaDatos(
          pagina,
          encabezado,
          logo,
          incluirFotosInline: !encabezado.imagenesSeparadas,
        ),
      ),
    );

    if (encabezado.imagenesSeparadas) {
      documento.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.letter,
          margin: const pw.EdgeInsets.all(24),
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          build: (context) => _construirHojaFotos(pagina, encabezado, logo),
        ),
      );
    }
  }

  return documento.save();
}

List<pw.Widget> _construirHojaDatos(
  List<Articulo> pagina,
  EncabezadoActa encabezado,
  pw.MemoryImage logo, {
  required bool incluirFotosInline,
}) {
  return [
    _encabezado(encabezado, logo),
    pw.SizedBox(height: 12),
    _tablaArticulos(pagina),
    pw.SizedBox(height: 4),
    pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        'TOTAL A DAR DE BAJA: ${formatMoneda(totalHojaActa(pagina))}',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
      ),
    ),
    pw.SizedBox(height: 12),
    if (incluirFotosInline) ...[
      _filaFotos(pagina),
      pw.SizedBox(height: 16),
    ],
    _seccionFirmas(),
  ];
}

/// Hoja dedicada a las fotografias de una hoja de datos, a mayor tamaño,
/// cuando el usuario elige "Imagenes separadas en el reporte". No lleva
/// firmas: es un anexo visual de la hoja de datos que la precede.
List<pw.Widget> _construirHojaFotos(
  List<Articulo> pagina,
  EncabezadoActa encabezado,
  pw.MemoryImage logo,
) {
  return [
    _encabezado(encabezado, logo),
    pw.SizedBox(height: 20),
    _cuadriculaFotosGrandes(pagina),
  ];
}

// Ancho de la columna izquierda (logo + leyenda) del encabezado, para que
// ambas filas queden alineadas una debajo de la otra como en el formato
// oficial (logo y leyenda a un costado, no centrados).
const _anchoColumnaLogo = 130.0;

pw.Widget _encabezado(EncabezadoActa encabezado, pw.MemoryImage logo) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.SizedBox(
            width: _anchoColumnaLogo,
            child: pw.Image(logo, height: 34),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Text(
              '- ACTA DE BAJA DE PRODUCTOS -',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                decoration: pw.TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 8),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: _anchoColumnaLogo,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Tortuga Resorts',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'San José SA de CV',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text(
                      'LOTE: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(encabezado.nombreLote),
                    pw.SizedBox(width: 24),
                    pw.Text(
                      'FECHA: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(encabezado.fechaFormateada),
                    pw.SizedBox(width: 24),
                    pw.Text(
                      'HORA: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(encabezado.hora),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  children: [
                    pw.Text(
                      'AREA: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(encabezado.area),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  children: [
                    pw.Text(
                      'DEPARTAMENTO: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(encabezado.departamento),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

const _anchosColumnasTabla = {
  0: pw.FlexColumnWidth(0.7),
  1: pw.FlexColumnWidth(1.3),
  2: pw.FlexColumnWidth(2.6),
  3: pw.FlexColumnWidth(1.1),
  4: pw.FlexColumnWidth(0.9),
  5: pw.FlexColumnWidth(1.1),
  6: pw.FlexColumnWidth(1.1),
};

pw.Widget _tablaArticulos(List<Articulo> pagina) {
  return pw.Table(
    border: pw.TableBorder.all(width: 0.5),
    columnWidths: _anchosColumnasTabla,
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          _celdaEncabezado('NUM.\nREF.'),
          _celdaEncabezado('CODIGO\nDEL ARTICULO'),
          _celdaEncabezado('DESCRIPCION'),
          _celdaEncabezado('UNIDAD DE\nMEDIDA'),
          _celdaEncabezado('CANTIDAD'),
          _celdaEncabezado('PRECIO\nUNITARIO'),
          _celdaEncabezado('PRECIO\nTOTAL'),
        ],
      ),
      for (var i = 0; i < articulosPorHojaActa; i++)
        _filaArticulo(i < pagina.length ? pagina[i] : null, i + 1),
    ],
  );
}

pw.Widget _celdaEncabezado(String texto) => pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        texto,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
      ),
    );

pw.Widget _celda(String texto, {pw.TextAlign align = pw.TextAlign.left}) =>
    pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(texto, textAlign: align, style: const pw.TextStyle(fontSize: 9)),
    );

pw.TableRow _filaArticulo(Articulo? articulo, int numeroRef) {
  if (articulo == null) {
    return pw.TableRow(
      children: [
        _celda(numeroRef.toString(), align: pw.TextAlign.center),
        _celda(''),
        _celda(''),
        _celda(''),
        _celda(''),
        _celda(''),
        _celda(''),
      ],
    );
  }
  return pw.TableRow(
    children: [
      _celda(numeroRef.toString(), align: pw.TextAlign.center),
      _celda(articulo.noSerie),
      _celda(articulo.descripcion),
      _celda(articulo.unidadMedida, align: pw.TextAlign.center),
      _celda(
        articulo.cantidad == articulo.cantidad.roundToDouble()
            ? articulo.cantidad.toInt().toString()
            : articulo.cantidad.toString(),
        align: pw.TextAlign.center,
      ),
      _celda(formatMoneda(articulo.precioUnitario), align: pw.TextAlign.right),
      _celda(formatMoneda(precioTotalArticulo(articulo)),
          align: pw.TextAlign.right),
    ],
  );
}

pw.Widget _filaFotos(List<Articulo> pagina) {
  return pw.Row(
    children: List.generate(
      articulosPorHojaActa,
      (i) => pw.Expanded(
        child: pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 2),
          child: _cajaFoto(
            i < pagina.length ? pagina[i] : null,
            i + 1,
            altura: 130,
            fontSizeNumero: 9,
          ),
        ),
      ),
    ),
  );
}

/// Cuadricula de 2 columnas (2+2+1) con las fotos a mayor tamaño para la
/// hoja dedicada de fotografias ("Imagenes separadas en el reporte").
pw.Widget _cuadriculaFotosGrandes(List<Articulo> pagina) {
  const alturaCaja = 190.0;
  final filas = <pw.Widget>[];
  for (var i = 0; i < articulosPorHojaActa; i += 2) {
    final quedaUnaSola = i + 1 >= articulosPorHojaActa;
    filas.add(
      // Sin crossAxisAlignment.stretch: dentro de un MultiPage, la primera
      // pasada mide el contenido con altura no acotada, y stretch fuerza esa
      // altura infinita hacia abajo como una restriccion tight, lo que
      // rompe el Expanded interno de _cajaFoto (altura ya es fija via
      // Container, no necesita stretch para igualarse).
      pw.Row(
        children: [
          pw.Expanded(
            child: _cajaFoto(
              i < pagina.length ? pagina[i] : null,
              i + 1,
              altura: alturaCaja,
              fontSizeNumero: 12,
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: quedaUnaSola
                ? pw.Container()
                : _cajaFoto(
                    (i + 1) < pagina.length ? pagina[i + 1] : null,
                    i + 2,
                    altura: alturaCaja,
                    fontSizeNumero: 12,
                  ),
          ),
        ],
      ),
    );
    filas.add(pw.SizedBox(height: 10));
  }
  return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: filas);
}

pw.Widget _cajaFoto(
  Articulo? articulo,
  int numero, {
  required double altura,
  required double fontSizeNumero,
}) {
  final fotoPath = articulo?.fotoPath;
  final tieneFoto = fotoPath != null && File(fotoPath).existsSync();
  return pw.Container(
    height: altura,
    decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
    child: pw.Column(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(3),
          child: pw.Text(
            '$numero',
            style: pw.TextStyle(
              fontSize: fontSizeNumero,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Expanded(
          child: tieneFoto
              ? pw.Padding(
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Image(
                    pw.MemoryImage(File(fotoPath).readAsBytesSync()),
                    fit: pw.BoxFit.contain,
                  ),
                )
              : pw.Container(),
        ),
      ],
    ),
  );
}

pw.Widget _seccionFirmas() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      _lineaFirma('Solicitado por:'),
      _lineaFirma('Aprobado por DOF:'),
      _lineaFirma('Diretor de Operaciones:'),
      pw.Container(
        margin: const pw.EdgeInsets.symmetric(vertical: 6),
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        color: PdfColors.grey300,
        child: pw.Text(
          'TESTIGOS',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        ),
      ),
      _lineaFirma('Por el Almacén:'),
      _lineaFirma('Por Seguridad:'),
      _lineaFirma('Por depto Solicitante:'),
    ],
  );
}

pw.Widget _lineaFirma(String etiqueta) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 6),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Text(etiqueta, style: const pw.TextStyle(fontSize: 9)),
        ),
        pw.Expanded(flex: 4, child: _campoEnBlanco('Firma:')),
        pw.SizedBox(width: 8),
        pw.Expanded(flex: 3, child: _campoEnBlanco('Fecha:')),
        pw.SizedBox(width: 8),
        pw.Expanded(flex: 2, child: _campoEnBlanco('Hora:')),
      ],
    ),
  );
}

pw.Widget _campoEnBlanco(String etiqueta) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: [
      pw.Text(etiqueta, style: const pw.TextStyle(fontSize: 9)),
      pw.SizedBox(width: 4),
      pw.Expanded(
        child: pw.Container(
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
          ),
          height: 12,
        ),
      ),
    ],
  );
}
