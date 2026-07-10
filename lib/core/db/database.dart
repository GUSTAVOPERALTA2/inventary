import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../data/models/campo_tipo.dart';
import 'converters/json_converters.dart';
import 'daos/articulos_dao.dart';
import 'daos/custom_field_definitions_dao.dart';
import 'daos/lotes_dao.dart';
import 'tables/articulos_table.dart';
import 'tables/custom_field_definitions_table.dart';
import 'tables/lotes_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Lotes, Articulos, CustomFieldDefinitions],
  daos: [LotesDao, ArticulosDao, CustomFieldDefinitionsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'app_inventario'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}
