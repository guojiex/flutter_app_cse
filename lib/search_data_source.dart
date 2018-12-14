import 'package:meta/meta.dart';

class SearchResult {}

abstract class SearchDataSource<SearchResult> {}

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
