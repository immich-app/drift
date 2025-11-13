import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

// #docregion background-simple
QueryExecutor openDatabase() {
  return NativeDatabase.createInBackground(File('path/to/database.db'));
}
// #enddocregion background-simple

// #docregion background-pool
QueryExecutor openMultiThreadedDatabase() {
  return NativeDatabase.createInBackground(
    File('path/to/database.db'),
    setup: (database) {
      // This is important, as accessing the database across threads otherwise
      // causes "database locked" errors.
      // With write-ahead logging (WAL) enabled, a single writer and multiple
      // readers can operate on the database in parallel.
      database.execute('pragma journal_mode = WAL;');
    },
    readPool: 4,
  );
}

// #enddocregion background-pool
