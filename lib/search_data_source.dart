import 'package:meta/meta.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import "package:googleapis_auth/auth_io.dart" as auth;
import 'package:googleapis/customsearch/v1.dart' as customsearch;
import 'package:english_words/english_words.dart';

// TODO: Use https://pub.dartlang.org/packages/url_launcher to let SearchResult capable to open apps.
/// A wrapper class for [customsearch.Result].
class SearchResult {
  final customsearch.Result result;

  SearchResult(this.result);

  @override
  String toString() {
    return 'title:${this.result.title}\nsnippet:${this.result.snippet}';
  }
}

/// Abstract class for Search Data Source.
abstract class SearchDataSource {
  Future<List<SearchResult>> search(String query, {String searchType});
}

class FakeSearchDataSource implements SearchDataSource {
  String jsonString;
  static const String _webSearchAssetPath = 'res/sampledata/nytimes_sample_data.json';
  static const String _imageSearchAssetPath = 'res/sampledata/nytimes_image_sample_data.json';

  FakeSearchDataSource({this.jsonString});

  FakeSearchDataSource.loadWebSearchResultFromAsset() {
    this._initFromAsset(_webSearchAssetPath);
  }

  FakeSearchDataSource.loadImageSearchResultFromAsset() {
    this._initFromAsset(_imageSearchAssetPath);
  }

  void _initFromAsset(String assetPath) {
    loadAsset(assetPath).then((loadedStr) => this.jsonString = loadedStr);
  }

  Future<String> loadAsset(String assetPath) async {
    return await rootBundle.loadString(assetPath);
  }

  @override
  Future<List<SearchResult>> search(String query, {String searchType}) async {
    Map searchMap = jsonDecode(jsonString);
    customsearch.Search search = customsearch.Search.fromJson(searchMap);
    var results = List<SearchResult>();
    search.items.forEach((item) => results.add(SearchResult(item)));
    return results;
  }
}

/// The search data source that uses Custom Search API.
class CustomSearchDataSource implements SearchDataSource {
  final String cx;
  final String apiKey;
  var api;

  CustomSearchDataSource({@required this.cx, @required this.apiKey}) {
    var client = auth.clientViaApiKey(apiKey);
    this.api = new customsearch.CustomsearchApi(client);
  }

  @override
  Future<List<SearchResult>> search(String query, {String searchType}) async {
    var results = List<SearchResult>();
    customsearch.Search search = await this.api.cse.list(
        query, cx: this.cx, searchType: searchType);
    if (search.items != null) {
      search.items.forEach((item) => results.add(SearchResult(item)));
    }
    return results;
  }
}

abstract class AutoCompleteDataSource {
  List<String> getAutoCompletions({String query, int resultNumber});
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
