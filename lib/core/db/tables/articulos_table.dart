import 'package:drift/drift.dart';

import '../converters/json_converters.dart';
import 'lotes_table.dart';

class Articulos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get loteId => integer().references(Lotes, #id)();
  TextColumn get noSerie => text()();
  TextColumn get descripcion => text()();
  RealColumn get cantidad => real()();
  TextColumn get fotoPath => text().nullable()();
  // Bloque 6: requeridos por el formato oficial del acta de baja (columnas
  // UNIDAD DE MEDIDA y PRECIO UNITARIO); PRECIO TOTAL se calcula al generar
  // el PDF (cantidad * precioUnitario), no se guarda.
  TextColumn get unidadMedida => text().withDefault(const Constant(''))();
  RealColumn get precioUnitario => real().withDefault(const Constant(0))();
  TextColumn get customValues => text().map(const MapJsonConverter())();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
  // Orden manual dentro del lote (arrastrar para reordenar en la lista);
  // determina tambien el orden en el PDF del acta y en el CSV del ZIP.
  // Los articulos existentes se migran usando su id (mismo orden que ya
  // tenian); los nuevos se crean al final (ver ArticulosRepository.crearArticulo).
  IntColumn get orden => integer().withDefault(const Constant(0))();
}
