import 'package:drift/drift.dart';

class Lotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text()();
  DateTimeColumn get fechaCreacion =>
      dateTime().clientDefault(() => DateTime.now())();
  // Orden manual (arrastrar para reordenar en la lista). Se muestra de
  // mayor a menor: un lote nuevo recibe el orden mas alto, para seguir
  // apareciendo arriba de todo como hasta ahora.
  IntColumn get orden => integer().withDefault(const Constant(0))();
}
