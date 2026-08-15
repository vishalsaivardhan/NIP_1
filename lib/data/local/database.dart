import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

part 'database.g.dart';

class Devices extends Table {
  TextColumn get id => text()();
  TextColumn get nodeType => text().nullable()();
  IntColumn get rssi => integer().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class Transactions extends Table {
  TextColumn get transactionId => text()();
  TextColumn get senderDeviceId => text()();
  TextColumn get receiverDeviceId => text()();
  IntColumn get amount => integer()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get status => text()();
  @override
  Set<Column> get primaryKey => {transactionId};
}

@DriftDatabase(tables: [Devices, Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'nip.sqlite'));
    return NativeDatabase(file);
  });
}
