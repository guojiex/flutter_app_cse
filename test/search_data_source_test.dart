import 'package:test/test.dart';
import 'package:flutter_app_cse/search_data_source.dart';
import 'dart:io';

void main() {
  SearchQuery query = SearchQuery('q', 'fake_cx');
  print(query.copyWith(start: 15));
}
