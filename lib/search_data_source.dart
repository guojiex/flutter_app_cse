import 'package:meta/meta.dart';
import 'dart:async';

import "package:googleapis_auth/auth_io.dart" as auth;
import 'package:googleapis/customsearch/v1.dart' as customsearch;

// TODO: Use https://pub.dartlang.org/packages/url_launcher to let SearchResult capable to open apps.
class SearchResult extends customsearch.Result {}

abstract class SearchDataSource {
  Future<List<SearchResult>> search(String query);
}

class FakeSearchDataSource implements SearchDataSource {
  @override
  Future<List<SearchResult>> search(String query) {
    return Future.value(List<SearchResult>(2));
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

  Future<List<customsearch.Result>> search(String query) async {
    return this.api.cse.list(query, cx: this.cx).then((
        customsearch.Search search) {
      if (search.items != null) {
        return search.items;
      } else {
        return new List<customsearch.Result>();
      }
    });
  }

  void _blockingSearch(String query) async {
    await this.api.cse.list(query, cx: this.cx).then((
        customsearch.Search search) {
      if (search.items != null) {
        for (var result in search.items) {
          print(result.snippet);
        }
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
