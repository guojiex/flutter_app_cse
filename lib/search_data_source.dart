import 'package:meta/meta.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import "package:googleapis_auth/auth_io.dart" as auth;
import 'package:googleapis/customsearch/v1.dart' as customsearch;
import 'package:english_words/english_words.dart';

// TODO: Use https://pub.dartlang.org/packages/url_launcher to let SearchResult capable to open apps.
class SearchResult {
  final customsearch.Result result;

  SearchResult(this.result);

  @override
  String toString() {
    return 'title:${this.result.title}\nsnippet:${this.result.snippet}';
  }
}

abstract class SearchDataSource {
  Future<List<SearchResult>> search(String query);
}

class FakeSearchDataSource implements SearchDataSource {
  String jsonString;

  FakeSearchDataSource(this.jsonString);

  void initFromAsset() {
    loadAsset().then((loadedStr) => this.jsonString = loadedStr);
  }

  Future<String> loadAsset() async {
    return await rootBundle
        .loadString('res/sampledata/nytimes_sample_data.json');
  }

  @override
  Future<List<SearchResult>> search(String query) async {
    Map searchMap = jsonDecode(jsonString);
    customsearch.Search search = customsearch.Search.fromJson(searchMap);
    var results = List<SearchResult>();
    search.items.forEach((item) => results.add(SearchResult(item)));
    return results;
  }
}

class CustomSearchJsonDataSource implements SearchDataSource {
  final String cx;
  final String apiKey;
  var api;

  CustomSearchJsonDataSource({@required this.cx, @required this.apiKey}) {
    var client = auth.clientViaApiKey(apiKey);
    this.api = new customsearch.CustomsearchApi(client);
  }

  @override
  Future<List<SearchResult>> search(String query) async {
    var results = List<SearchResult>();
    customsearch.Search search = await this.api.cse.list(query, cx: this.cx);
    if (search.items != null) {
      search.items.forEach((item) => results.add(SearchResult(item)));
    }
    return results;
  }
}

abstract class AutoCompleteDataSource {
  List<String> getAutoCompletions({String query, int resultNumber});
}

class FakeAutoCompleteDataSource implements AutoCompleteDataSource {
  @override
  List<String> getAutoCompletions(
      {@required String query, int resultNumber = 10}) {
    assert(resultNumber > 0);
    return ['car', 'a', 'day'].sublist(0, resultNumber);
  }
}

class CommonEnglishWordAutoCompleteDataSource
    implements AutoCompleteDataSource {
  @override
  List<String> getAutoCompletions({String query, int resultNumber = 10}) {
    var results = all.where((String word) => word.startsWith(query)).toList();
    return results.length > resultNumber
        ? results.sublist(0, resultNumber)
        : results;
  }
}
