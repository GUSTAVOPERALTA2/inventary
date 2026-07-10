import 'dart:convert';

import 'package:drift/drift.dart';

/// Serializa un `Map<String, dynamic>` (p.ej. articulos.custom_values) como texto JSON.
class MapJsonConverter extends TypeConverter<Map<String, dynamic>, String> {
  const MapJsonConverter();

  @override
  Map<String, dynamic> fromSql(String fromDb) =>
      jsonDecode(fromDb) as Map<String, dynamic>;

  @override
  String toSql(Map<String, dynamic> value) => jsonEncode(value);
}

/// Serializa una `List<String>` (p.ej. custom_field_definitions.opciones) como texto JSON.
class StringListJsonConverter extends TypeConverter<List<String>, String> {
  const StringListJsonConverter();

  @override
  List<String> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List<dynamic>).cast<String>();

  @override
  String toSql(List<String> value) => jsonEncode(value);
}
