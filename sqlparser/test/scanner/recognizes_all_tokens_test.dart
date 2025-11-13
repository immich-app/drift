@TestOn('vm')
library;

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:sqlparser/src/reader/tokenizer/token.dart';
import 'package:test/test.dart';

typedef SqliteKeywordCountNative = Int32 Function();
typedef SqliteKeywordCount = int Function();

typedef SqliteKeywordNameNative = Int32 Function(
    Int32, Pointer<Pointer<Uint8>>, Pointer<Int32>);
typedef SqliteKeywordName = int Function(
    int, Pointer<Pointer<Uint8>>, Pointer<Int32>);

void main() {
  String? skip;
  late DynamicLibrary library;

  try {
    if (Platform.isLinux) {
      library = DynamicLibrary.open('libsqlite3.so');
    } else if (Platform.isMacOS) {
      library = DynamicLibrary.open('libsqlite3.dylib');
    } else if (Platform.isWindows) {
      library = DynamicLibrary.open('sqlite3.dll');
    } else {
      skip = 'Unknown host OS';
    }

    // Some platforms have sqlite3, but no sqlite3_keyword_count
    library.lookup('sqlite3_keyword_count');
  } on Object {
    skip = 'sqlite3 is not available in test environment';
  }

  test(
    'recognizes all sqlite keywords',
    () {
      final keywordCount =
          library.lookupFunction<SqliteKeywordCountNative, SqliteKeywordCount>(
              'sqlite3_keyword_count')();
      final nameFunction =
          library.lookupFunction<SqliteKeywordNameNative, SqliteKeywordName>(
              'sqlite3_keyword_name');

      final charOut = malloc<Pointer<Uint8>>();
      final lengthOut = malloc<Int32>();

      final missingNames = <String>[];

      for (var i = 0; i < keywordCount; i++) {
        nameFunction(i, charOut, lengthOut);

        final bytes = charOut.value.asTypedList(lengthOut.value);
        final name = utf8.decode(bytes);

        if (!keywords.containsKey(name)) {
          missingNames.add(name);
        }
      }

      missingNames.sort();

      malloc.free(charOut);
      malloc.free(lengthOut);

      expect(missingNames, isEmpty);
    },
    skip: skip,
  );
}
