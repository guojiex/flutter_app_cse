import 'package:test/test.dart';
import 'package:flutter_app_cse/search_data_source.dart';
import 'dart:io';

void main() {
  test('fake autocomplete data source test', () {
    var data_source = FakeAutoCompleteDataSource();
    expect(data_source.getAutoCompletions(query: ''),
        ['abcd', 'efgh', 'efdfsjd'].toList());
  });
  test('json decode test', () async {
    await new File('../res/sampledata/test_search_result.json')
        .readAsString()
        .then((String contents) {
      var dataSource = FakeSearchDataSource(contents);
      dataSource.search('whatever').then((searchResult) {
        searchResult.forEach((result) => print(result));
      });
    });
  });
//  test('CSE data source test', () {
//    final apiKey = '<please-fill-in>';
//    var data_source = CustomSearchJsonDataSource(
//        cx: '008795855128244970711:yafufe8jjt8', apiKey: apiKey);
//    data_source._blockingSearchPrint('test');
//  });
}
