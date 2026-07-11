import 'package:app_inventario/core/utils/cantidad_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseCantidad', () {
    test('en modo entero acepta solo digitos', () {
      expect(parseCantidad('5', esEntero: true), 5.0);
      expect(parseCantidad('5.5', esEntero: true), isNull);
      expect(parseCantidad('', esEntero: true), isNull);
    });

    test('en modo decimal acepta punto y coma como separador', () {
      expect(parseCantidad('2.5', esEntero: false), 2.5);
      expect(parseCantidad('2,5', esEntero: false), 2.5);
      expect(parseCantidad('abc', esEntero: false), isNull);
    });
  });

  group('formatCantidad', () {
    test('sin decimales cuando el valor es entero', () {
      expect(formatCantidad(5.0), '5');
    });

    test('con decimales cuando el valor es fraccionario', () {
      expect(formatCantidad(2.5), '2.5');
    });
  });
}
