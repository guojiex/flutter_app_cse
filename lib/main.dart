import 'package:flutter/material.dart';
import 'package:flutter_app_cse/ui/custom_search_demo_page.dart';

void main() => runApp(SearchDemoApp());

class SearchDemoApp extends StatelessWidget {
  final CustomSearchDemoPage webSearchDemo =
  CustomSearchDemoPage(CustomSearchDemoType.webSearch);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: webSearchDemo,
        initialRoute: '/websearch',
        routes: {
          '/websearch': (context) => webSearchDemo,
          '/imagesearch': (context) =>
              CustomSearchDemoPage(CustomSearchDemoType.imageSearch),
        },
        title: 'Custom Search Engine Flutter Demo');
  }
}
