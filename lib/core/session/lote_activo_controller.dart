import 'package:flutter/foundation.dart';

/// Id del lote activo en la sesion actual de la app (en memoria, no
/// persistido: un lote es "cada sesion de captura/reporte", no algo que
/// deba sobrevivir a cerrar la app).
class LoteActivoController extends ValueNotifier<int?> {
  LoteActivoController() : super(null);

  void seleccionar(int loteId) => value = loteId;

  void limpiar() => value = null;
}
