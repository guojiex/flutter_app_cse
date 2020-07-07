import 'package:flutter/material.dart';
import 'package:flutter_app_cse/ui/custom_search_demo_page.dart';

void main() => runApp(SearchDemoApp());

class SearchDemoApp extends StatelessWidget {
  static const API_KEY = '';
  final CustomSearchDemoPage webSearchDemo =
      CustomSearchDemoPage(CustomSearchDemoType.webSearch, API_KEY);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: webSearchDemo,
        initialRoute: '/websearch',
        routes: {
          '/websearch': (context) => webSearchDemo,
          '/imagesearch': (context) =>
              CustomSearchDemoPage(CustomSearchDemoType.imageSearch, API_KEY),
          '/promotionwebsearch': (context) => CustomSearchDemoPage(
              CustomSearchDemoType.promotionWebSearch, API_KEY),
          '/mixsearch': (context) =>
              CustomSearchDemoPage(CustomSearchDemoType.mixSearch, API_KEY),
        },
        title: 'Custom Search Engine Flutter Demo');
  }
}
