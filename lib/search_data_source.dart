import 'package:meta/meta.dart';
import 'dart:async';
import 'dart:convert';

import "package:googleapis_auth/auth_io.dart" as auth;
import 'package:googleapis/customsearch/v1.dart' as customsearch;

// TODO: Use https://pub.dartlang.org/packages/url_launcher to let SearchResult capable to open apps.
class SearchResult {
  final customsearch.Result _result;

  SearchResult(this._result);

  @override
  String toString() {
    return 'title:${this._result.htmlTitle}\nsnippet:${this._result
        .htmlSnippet}';
  }
}

abstract class SearchDataSource {
  Future<List<SearchResult>> search(String query);
}

class FakeSearchDataSource implements SearchDataSource {
  final String jsonString;

  FakeSearchDataSource(this.jsonString);

  @override
  Future<List<SearchResult>> search(String query) async {
    Map searchMap = jsonDecode(jsonString);
    customsearch.Search search = customsearch.Search.fromJson(searchMap);
    var results = List<SearchResult>();
    search.items.forEach((item) => results.add(SearchResult(item)));
    return results;
  }
}

class CustomSearchJsonDataSource {
  final String cx;
  final String apiKey;
  var api;

  CustomSearchJsonDataSource({@required this.cx, @required this.apiKey}) {
    var client = auth.clientViaApiKey(apiKey);
    this.api = new customsearch.CustomsearchApi(client);
  }

  Future<List<SearchResult>> search(String query) {
    return this
        .api
        .cse
        .list(query, cx: this.cx)
        .then((customsearch.Search search) {
      if (search.items != null) {
        return search.items;
      } else {
        return new List<customsearch.Result>();
      }
    });
  }
}

abstract class AutoCompleteDataSource {
  List<String> getAutoCompletions({String query, int resultNumber});
}

class FakeAutoCompleteDataSource implements AutoCompleteDataSource {
  @override
  List<String> getAutoCompletions(
      {@required String query, int resultNumber = 3}) {
    assert(resultNumber > 0);
    return ['abcd', 'efgh', 'efdfsjd'].sublist(0, resultNumber);
  }
}
