import 'package:moor/moor.dart';

class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 6, max: 32)();
  TextColumn get content => text().named('body')();
  BoolColumn get completed => boolean().withDefault(Constant(false))();
}