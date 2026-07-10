import 'package:drift/drift.dart';

class Lotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text()();
  DateTimeColumn get fechaCreacion =>
      dateTime().clientDefault(() => DateTime.now())();
}
