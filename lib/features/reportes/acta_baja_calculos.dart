import '../../core/db/database.dart';

/// El acta de baja oficial trae 5 artículos por hoja (5 filas en la tabla,
/// 5 recuadros de fotos numerados debajo). Un lote con más artículos genera
/// varias hojas, cada una completa con su propio total y firmas.
const int articulosPorHojaActa = 5;

List<List<Articulo>> paginarArticulosActa(
  List<Articulo> articulos, {
  int porHoja = articulosPorHojaActa,
}) {
  final paginas = <List<Articulo>>[];
  for (var i = 0; i < articulos.length; i += porHoja) {
    final fin = (i + porHoja < articulos.length) ? i + porHoja : articulos.length;
    paginas.add(articulos.sublist(i, fin));
  }
  return paginas;
}

/// PRECIO TOTAL de una fila = cantidad * precio unitario.
double precioTotalArticulo(Articulo articulo) =>
    articulo.cantidad * articulo.precioUnitario;

/// TOTAL A DAR DE BAJA de una hoja = suma del PRECIO TOTAL de sus artículos.
double totalHojaActa(List<Articulo> articulosDeLaHoja) => articulosDeLaHoja.fold(
      0.0,
      (acumulado, articulo) => acumulado + precioTotalArticulo(articulo),
    );

String formatMoneda(double valor) => '\$${valor.toStringAsFixed(2)}';
