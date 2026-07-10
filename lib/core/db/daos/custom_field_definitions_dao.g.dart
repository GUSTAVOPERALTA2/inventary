// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_field_definitions_dao.dart';

// ignore_for_file: type=lint
mixin _$CustomFieldDefinitionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomFieldDefinitionsTable get customFieldDefinitions =>
      attachedDatabase.customFieldDefinitions;
  CustomFieldDefinitionsDaoManager get managers =>
      CustomFieldDefinitionsDaoManager(this);
}

class CustomFieldDefinitionsDaoManager {
  final _$CustomFieldDefinitionsDaoMixin _db;
  CustomFieldDefinitionsDaoManager(this._db);
  $$CustomFieldDefinitionsTableTableManager get customFieldDefinitions =>
      $$CustomFieldDefinitionsTableTableManager(
        _db.attachedDatabase,
        _db.customFieldDefinitions,
      );
}
