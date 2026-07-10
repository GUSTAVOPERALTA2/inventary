import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/lotes_table.dart';

part 'lotes_dao.g.dart';

@DriftAccessor(tables: [Lotes])
class LotesDao extends DatabaseAccessor<AppDatabase> with _$LotesDaoMixin {
  LotesDao(super.db);

  Stream<List<Lote>> watchAllLotes() =>
      (select(lotes)
            ..orderBy([(t) => OrderingTerm.desc(t.fechaCreacion)]))
          .watch();

  Future<Lote> getLoteById(int id) =>
      (select(lotes)..where((t) => t.id.equals(id))).getSingle();

  Future<int> insertLote(LotesCompanion entry) => into(lotes).insert(entry);
}
