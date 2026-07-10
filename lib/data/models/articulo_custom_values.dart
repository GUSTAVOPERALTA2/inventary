import '../../core/db/database.dart';

/// Lectura tipada del JSON de custom_values de un artículo, sin exponer
/// jsonDecode/Encode fuera de la capa de datos.
extension ArticuloCustomValues on Articulo {
  dynamic valorCampo(String nombreCampo) => customValues[nombreCampo];
}
