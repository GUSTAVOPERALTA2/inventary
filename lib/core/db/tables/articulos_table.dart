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
  TextColumn get customValues => text().map(const MapJsonConverter())();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
}
