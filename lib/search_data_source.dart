import 'package:meta/meta.dart';

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

class CustomSearchJsonDataSource implements SearchDataSource {
  final String cx;

  CustomSearchJsonDataSource(this.cx);

  @override
  List<SearchResult> search(String query) {}
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
