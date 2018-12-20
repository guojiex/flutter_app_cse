import 'package:meta/meta.dart';
import 'dart:async';

import "package:googleapis_auth/auth_io.dart" as auth;
import 'package:googleapis/customsearch/v1.dart';
import 'package:_discoveryapis_commons/_discoveryapis_commons.dart';

// TODO: Use https://pub.dartlang.org/packages/url_launcher to let SearchResult capable to open apps.
@immutable
class SearchResult {
  final String title;
  final String link;
  final String snippet;

  SearchResult(this.title, this.link, this.snippet);
}

abstract class SearchDataSource {
  List<SearchResult> search(String query);
}

class FakeSearchDataSource implements SearchDataSource {
  @override
  List<SearchResult> search(String query) {
    return [new SearchResult('title', 'www.google.com', 'A fake test example')]
        .toList();
  }
}

class CustomSearchJsonDataSource {
  final String cx;
  final String apiKey;
  var api;

  CustomSearchJsonDataSource({@required this.cx, @required this.apiKey}) {
    var client = auth.clientViaApiKey(apiKey);
    this.api = new CustomsearchApi(client);
  }

  void search(String query) async {
    await this.api.cse.list(query, cx: this.cx).then((Search search) {
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
