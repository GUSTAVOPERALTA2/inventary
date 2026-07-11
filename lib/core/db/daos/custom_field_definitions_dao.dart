import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/custom_field_definitions_table.dart';

part 'custom_field_definitions_dao.g.dart';

@DriftAccessor(tables: [CustomFieldDefinitions])
class CustomFieldDefinitionsDao extends DatabaseAccessor<AppDatabase>
    with _$CustomFieldDefinitionsDaoMixin {
  CustomFieldDefinitionsDao(super.db);

  /// Solo las definiciones activas, para el formulario dinámico de captura.
  Stream<List<CustomFieldDefinition>> watchActiveDefinitions() =>
      (select(customFieldDefinitions)
            ..where((t) => t.activo.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.orden)]))
          .watch();

  /// Todas, incluidas las inactivas, para la pantalla de gestión de campos.
  Stream<List<CustomFieldDefinition>> watchAllDefinitions() =>
      (select(customFieldDefinitions)
            ..orderBy([(t) => OrderingTerm.asc(t.orden)]))
          .watch();

  /// Snapshot puntual (sin watch) de las definiciones activas y su conteo
  /// total, usados al abrir el formulario de artículo y al asignar el
  /// siguiente `orden` para una definición nueva.
  Future<List<CustomFieldDefinition>> getActiveDefinitions() =>
      (select(customFieldDefinitions)
            ..where((t) => t.activo.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.orden)]))
          .get();

  Future<int> countDefinitions() =>
      select(customFieldDefinitions).get().then((rows) => rows.length);

  Future<int> insertDefinition(CustomFieldDefinitionsCompanion entry) =>
      into(customFieldDefinitions).insert(entry);

  Future<bool> updateDefinition(CustomFieldDefinitionsCompanion entry) =>
      update(customFieldDefinitions).replace(entry);

  /// Borrado lógico: nunca se borra físicamente para no romper reportes
  /// históricos de lotes que ya capturaron valores de este campo.
  Future<int> softDeleteDefinition(int id) =>
      (update(customFieldDefinitions)..where((t) => t.id.equals(id)))
          .write(const CustomFieldDefinitionsCompanion(activo: Value(false)));
}
