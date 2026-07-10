import 'package:drift/drift.dart';

import '../../../data/models/campo_tipo.dart';
import '../converters/json_converters.dart';

class CustomFieldDefinitions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text()();
  TextColumn get tipo => textEnum<CampoTipo>()();
  TextColumn get opciones =>
      text().map(const StringListJsonConverter()).nullable()();
  IntColumn get orden => integer()();
  BoolColumn get activo => boolean().clientDefault(() => true)();
}
