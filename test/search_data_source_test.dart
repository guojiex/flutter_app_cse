import 'package:test/test.dart';
import 'package:flutter_app_cse/search_data_source.dart';

void main() {
  test('fake autocomplete data source test', () {
    var data_source = FakeAutoCompleteDataSource();
    expect(data_source.getAutoCompletions(query: ''),
        ['abcd', 'efgh', 'efdfsjd'].toList());
  });
}
