/// La cantidad de un articulo siempre se guarda como REAL en la base de
/// datos; el switch entero/decimal es solo de la capa de
/// validacion/visualizacion, para que el mismo campo sirva para ambos casos
/// sin migrar nada.
library;

/// Devuelve la cantidad parseada, o null si el texto no es valido para el
/// modo elegido (enteros no aceptan punto decimal).
double? parseCantidad(String texto, {required bool esEntero}) {
  final normalizado = texto.trim().replaceAll(',', '.');
  if (normalizado.isEmpty) return null;

  if (esEntero) {
    return int.tryParse(normalizado)?.toDouble();
  }
  return double.tryParse(normalizado);
}

/// Formatea una cantidad ya guardada para mostrarla: sin decimales si es un
/// numero entero, con decimales si no lo es.
String formatCantidad(double cantidad) {
  if (cantidad == cantidad.roundToDouble()) {
    return cantidad.toInt().toString();
  }
  return cantidad.toString();
}
