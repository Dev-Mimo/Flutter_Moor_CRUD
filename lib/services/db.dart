import 'package:moor/moor.dart';
import 'package:moor_flutter_example/models/todos.dart';
import 'package:moor_flutter_example/daos/todos_dao.dart';

// These imports are only needed to open the database:
import 'package:moor/ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'db.g.dart';

// Opens the connection to SQLite DB:
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return VmDatabase(file);
  });
}

// Actual CRUD operation is here:
@UseMoor(tables: [Todos], daos: [TodosDao])
class MyDB extends _$MyDB {
  MyDB() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
      onCreate: (Migrator m) {
        return m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1) {
          // we added the dueDate property in the change from version 1
          // Insert changes below:
          // await m.addColumn(todos, todos.dueDate);
        }
      }
  );

}
