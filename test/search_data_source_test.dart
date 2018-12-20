import 'package:test/test.dart';
import 'package:flutter_app_cse/search_data_source.dart';

void main() {
  test('fake autocomplete data source test', () {
    var data_source = FakeAutoCompleteDataSource();
    expect(data_source.getAutoCompletions(query: ''),
        ['abcd', 'efgh', 'efdfsjd'].toList());
  });
//  test('CSE data source test', () {
//    final apiKey = '<please-fill-in>';
//    var data_source = CustomSearchJsonDataSource(
//        cx: '008795855128244970711:yafufe8jjt8', apiKey: apiKey);
//    data_source.search('test');
//  });
}
