import 'package:meta/meta.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import "package:googleapis_auth/auth_io.dart" as auth;
import 'package:googleapis/customsearch/v1.dart' as customsearch;
import 'package:english_words/english_words.dart';

/// A wrapper class for [customsearch.Result].
/// [SearchResult] will use the landing page link to measure if two results are
/// the same. This is useful for deduplicate image search result.
class SearchResult {
  final customsearch.Result result;

  SearchResult(this.result);

  SearchResult.escapeLineBreakInSnippet(this.result) {
    this.result.snippet = this.result.snippet.replaceAll("\n", "");
  }

  @override
  String toString() {
    return 'title:${this.result.title}\nsnippet:${this.result.snippet}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    // Use landing page link to see if two results are the same.
    if (this.result.image != null) {
      return other is SearchResult &&
          runtimeType == other.runtimeType &&
          result.image.contextLink == other.result.image.contextLink;
    } else {
      return other is SearchResult &&
          runtimeType == other.runtimeType &&
          result.link == other.result.link;
    }
  }

  @override
  int get hashCode =>
      result.image == null
          ? result.link.hashCode
          : result.image.contextLink.hashCode;
}

/// Abstract class for Search Data Source.
abstract class SearchDataSource {
  Future<List<SearchResult>> search(String query, {String searchType});
}

class _StaticSearchResponse {
  final String assetPath;
  final String searchType;
  String searchResponseJsonString;

  _StaticSearchResponse(
      {this.assetPath, this.searchType, this.searchResponseJsonString});
}


class FakeSearchDataSource implements SearchDataSource {

  final Map<String, _StaticSearchResponse> searchResponses = {
    'web': _StaticSearchResponse(
        assetPath: 'res/sampledata/nytimes_sample_data.json'),
    'image': _StaticSearchResponse(
        assetPath: 'res/sampledata/nytimes_sample_data.json',
        searchType: 'image'),
    'promotion': _StaticSearchResponse(
        assetPath: 'res/sampledata/nytimes_with_promotion.json'),
  };


  FakeSearchDataSource() {
    searchResponses.keys.forEach((key) {
      loadAssetToSearchResponse(key, searchResponses[key].assetPath);
    });
  }

  void loadAssetToSearchResponse(String searchKey, String assetPath) async {
    searchResponses[searchKey].searchResponseJsonString =
    await rootBundle.loadString(assetPath);
  }

  @override
  Future<List<SearchResult>> search(String query, {String searchType}) async {
    var results = List<SearchResult>();
    if (!searchResponses.containsKey(query)) {
      return results;
    }
    if (searchResponses[query].searchType != searchType) {
      return results;
    }
    Map searchMap = jsonDecode(searchResponses[query].searchResponseJsonString);
    customsearch.Search search = customsearch.Search.fromJson(searchMap);
    search.items.forEach(
            (item) => results.add(SearchResult.escapeLineBreakInSnippet(item)));
    return Set<SearchResult>.from(results).toList();
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
    customsearch.Search search =
        await this.api.cse.list(query, cx: this.cx, searchType: searchType);
    if (search.items != null) {
      search.items.forEach((item) => results.add(SearchResult(item)));
    }
    return Set<SearchResult>.from(results).toList();
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
