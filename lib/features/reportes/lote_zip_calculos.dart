import '../../core/db/database.dart';
import '../../data/models/campo_tipo.dart';
import 'acta_baja_calculos.dart';

/// Reemplaza los caracteres invalidos para nombres de archivo en
/// Windows/Android por guion bajo.
String sanitizarNombreArchivo(String texto) {
  final limpio = texto.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  return limpio.isEmpty ? 'sin_nombre' : limpio;
}

String _dosDigitos(int valor) => valor.toString().padLeft(2, '0');

/// Nombre del ZIP exportado para un lote, con marca de tiempo para no
/// pisar exportaciones previas del mismo lote.
String nombreArchivoZipLote(String nombreLote, DateTime momento) {
  final marca = '${momento.year}${_dosDigitos(momento.month)}'
      '${_dosDigitos(momento.day)}_${_dosDigitos(momento.hour)}'
      '${_dosDigitos(momento.minute)}${_dosDigitos(momento.second)}';
  return 'Lote_${sanitizarNombreArchivo(nombreLote)}_$marca.zip';
}

/// Nombre del archivo de foto dentro del ZIP. Se antepone el id del
/// articulo para garantizar unicidad aunque dos articulos compartan
/// no. de serie.
String nombreArchivoFotoZip(Articulo articulo, String extensionOriginal) {
  return '${articulo.id}_${sanitizarNombreArchivo(articulo.noSerie)}$extensionOriginal';
}

String _formatValorCampo(dynamic valor, CampoTipo tipo) {
  if (valor == null) return '';
  if (tipo == CampoTipo.fecha) {
    final fecha = DateTime.tryParse(valor as String);
    if (fecha == null) return '';
    return '${_dosDigitos(fecha.day)}-${_dosDigitos(fecha.month)}-${fecha.year}';
  }
  return valor.toString();
}

String _celdaCsv(String valor) {
  final necesitaComillas =
      valor.contains(',') || valor.contains('"') || valor.contains('\n');
  if (!necesitaComillas) return valor;
  return '"${valor.replaceAll('"', '""')}"';
}

/// Construye el CSV con el resumen de articulos del lote, incluyendo los
/// valores de los campos configurables. Se reciben todas las
/// definiciones (activas e historicas) para que un campo ya desactivado
/// siga mostrando su columna si algun articulo del lote lo capturo.
String construirCsvArticulos(
  List<Articulo> articulos,
  List<CustomFieldDefinition> definiciones,
) {
  final encabezados = [
    'No. Serie',
    'Descripcion',
    'Cantidad',
    'Unidad de medida',
    'Precio unitario',
    'Precio total',
    ...definiciones.map((d) => d.nombre),
    'Foto',
  ];

  final filas = <String>[encabezados.map(_celdaCsv).join(',')];
  for (final articulo in articulos) {
    final celdas = [
      articulo.noSerie,
      articulo.descripcion,
      articulo.cantidad == articulo.cantidad.roundToDouble()
          ? articulo.cantidad.toInt().toString()
          : articulo.cantidad.toString(),
      articulo.unidadMedida,
      formatMoneda(articulo.precioUnitario),
      formatMoneda(precioTotalArticulo(articulo)),
      ...definiciones.map(
        (d) => _formatValorCampo(
          articulo.customValues[d.id.toString()],
          d.tipo,
        ),
      ),
      articulo.fotoPath == null ? 'Sin foto' : 'Ver carpeta fotos/',
    ];
    filas.add(celdas.map(_celdaCsv).join(','));
  }
  return filas.join('\r\n');
}
