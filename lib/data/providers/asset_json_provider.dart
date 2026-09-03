import 'dart:convert';

import 'package:flutter/services.dart';

import '../../core/errors/data_exception.dart';

class AssetJsonProvider {
  Future<List<String>> readCommaSeparated(String path) async {
    try {
      final source = await rootBundle.loadString(path);
      return source
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
    } on Object catch (error) {
      throw DataException('Unable to read $path', error);
    }
  }

  Future<List<Map<String, dynamic>>> readList(String path) async {
    try {
      final source = await rootBundle.loadString(path);
      final value = jsonDecode(source);
      if (value is! List) {
        throw DataException('$path must contain a JSON array');
      }
      return value.cast<Map<String, dynamic>>();
    } on DataException {
      rethrow;
    } on Object catch (error) {
      throw DataException('Unable to read $path', error);
    }
  }
}
