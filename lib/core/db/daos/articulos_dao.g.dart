// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'articulos_dao.dart';

// ignore_for_file: type=lint
mixin _$ArticulosDaoMixin on DatabaseAccessor<AppDatabase> {
  $LotesTable get lotes => attachedDatabase.lotes;
  $ArticulosTable get articulos => attachedDatabase.articulos;
  ArticulosDaoManager get managers => ArticulosDaoManager(this);
}

class ArticulosDaoManager {
  final _$ArticulosDaoMixin _db;
  ArticulosDaoManager(this._db);
  $$LotesTableTableManager get lotes =>
      $$LotesTableTableManager(_db.attachedDatabase, _db.lotes);
  $$ArticulosTableTableManager get articulos =>
      $$ArticulosTableTableManager(_db.attachedDatabase, _db.articulos);
}
