// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lotes_dao.dart';

// ignore_for_file: type=lint
mixin _$LotesDaoMixin on DatabaseAccessor<AppDatabase> {
  $LotesTable get lotes => attachedDatabase.lotes;
  LotesDaoManager get managers => LotesDaoManager(this);
}

class LotesDaoManager {
  final _$LotesDaoMixin _db;
  LotesDaoManager(this._db);
  $$LotesTableTableManager get lotes =>
      $$LotesTableTableManager(_db.attachedDatabase, _db.lotes);
}
