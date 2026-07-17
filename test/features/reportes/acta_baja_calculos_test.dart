import 'package:app_inventario/core/db/database.dart';
import 'package:app_inventario/features/reportes/acta_baja_calculos.dart';
import 'package:flutter_test/flutter_test.dart';

Articulo _articulo({
  int id = 1,
  double cantidad = 1,
  double precioUnitario = 0,
}) {
  return Articulo(
    id: id,
    loteId: 1,
    noSerie: 'SN-$id',
    descripcion: 'Articulo $id',
    cantidad: cantidad,
    unidadMedida: 'Pieza',
    precioUnitario: precioUnitario,
    customValues: const {},
    createdAt: DateTime(2026, 1, 1),
    orden: id,
  );
}

void main() {
  group('paginarArticulosActa', () {
    test('una lista vacia no genera hojas', () {
      expect(paginarArticulosActa(const []), isEmpty);
    });

    test('5 articulos o menos caben en una sola hoja', () {
      final articulos = List.generate(5, (i) => _articulo(id: i + 1));
      final paginas = paginarArticulosActa(articulos);
      expect(paginas, hasLength(1));
      expect(paginas.single, hasLength(5));
    });

    test('6 articulos generan dos hojas, la segunda con 1', () {
      final articulos = List.generate(6, (i) => _articulo(id: i + 1));
      final paginas = paginarArticulosActa(articulos);
      expect(paginas, hasLength(2));
      expect(paginas[0], hasLength(5));
      expect(paginas[1], hasLength(1));
    });

    test('12 articulos generan tres hojas de 5, 5 y 2', () {
      final articulos = List.generate(12, (i) => _articulo(id: i + 1));
      final paginas = paginarArticulosActa(articulos);
      expect(paginas.map((p) => p.length), [5, 5, 2]);
    });
  });

  group('precioTotalArticulo y totalHojaActa', () {
    test('precio total de una fila es cantidad * precio unitario', () {
      final articulo = _articulo(cantidad: 3, precioUnitario: 150);
      expect(precioTotalArticulo(articulo), 450);
    });

    test('el total de la hoja suma el precio total de cada articulo', () {
      final pagina = [
        _articulo(id: 1, cantidad: 2, precioUnitario: 100),
        _articulo(id: 2, cantidad: 1, precioUnitario: 50),
        _articulo(id: 3, cantidad: 3, precioUnitario: 10),
      ];
      // 200 + 50 + 30 = 280
      expect(totalHojaActa(pagina), 280);
    });

    test('una hoja vacia totaliza 0', () {
      expect(totalHojaActa(const []), 0);
    });
  });

  group('formatMoneda', () {
    test('siempre muestra dos decimales, incluso en valores enteros', () {
      expect(formatMoneda(150), r'$150.00');
      expect(formatMoneda(99.5), r'$99.50');
      expect(formatMoneda(0), r'$0.00');
    });
  });
}
