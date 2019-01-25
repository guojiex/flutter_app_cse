import 'package:flutter/material.dart';
import 'package:flutter_app_cse/CustomSearchPage.dart';

void main() => runApp(SearchDemoApp());

class SearchDemoApp extends StatelessWidget {
  CustomSearchDemo webSearchDemo =
  CustomSearchDemo(CustomSearchDemoType.staticWebSearch);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: webSearchDemo,
        initialRoute: '/websearch',
        routes: {
          '/websearch': (context) => webSearchDemo,
          '/imagesearch': (context) =>
              CustomSearchDemo(CustomSearchDemoType.staticImageSearch),
        },
        title: 'Custom Search Engine Flutter Demo');
  }
}
