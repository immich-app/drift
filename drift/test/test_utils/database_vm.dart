import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';

Object? transportRoundtrip(Object? source) {
  return source;
}

Version get sqlite3Version {
  return sqlite3.version;
}

DatabaseConnection testInMemoryDatabase() {
  return DatabaseConnection(NativeDatabase.memory(setup: (rawDb) {
    rawDb.config.doubleQuotedStringLiterals = false;
  }));
}
