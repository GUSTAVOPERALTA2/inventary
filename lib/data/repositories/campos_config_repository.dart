import 'package:drift/drift.dart';

import '../../core/db/daos/custom_field_definitions_dao.dart';
import '../../core/db/database.dart';
import '../models/campo_tipo.dart';

class CamposConfigRepository {
  CamposConfigRepository(this._dao);

  final CustomFieldDefinitionsDao _dao;

  Stream<List<CustomFieldDefinition>> watchActiveDefinitions() =>
      _dao.watchActiveDefinitions();

  Stream<List<CustomFieldDefinition>> watchAllDefinitions() =>
      _dao.watchAllDefinitions();

  Future<int> crearDefinicion({
    required String nombre,
    required CampoTipo tipo,
    List<String>? opciones,
    required int orden,
  }) =>
      _dao.insertDefinition(CustomFieldDefinitionsCompanion.insert(
        nombre: nombre,
        tipo: tipo,
        opciones: Value(opciones),
        orden: orden,
      ));

  Future<bool> actualizarDefinicion(CustomFieldDefinition definicion) =>
      _dao.updateDefinition(definicion.toCompanion(true));

  /// Borrado lógico (activo = false): los reportes históricos que ya
  /// capturaron valores de este campo siguen íntegros.
  Future<int> eliminarDefinicion(int id) => _dao.softDeleteDefinition(id);
}
