import 'package:flutter/material.dart';
import 'package:flutter_app_cse/CustomWebSearchPage.dart';
import 'package:flutter_app_cse/CustomImageSearchPage.dart';

void main() => runApp(SearchDemoApp());

class SearchDemoApp extends StatelessWidget {
  CustomWebSearchDemo webSearchDemo = CustomWebSearchDemo();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: webSearchDemo,
        initialRoute: '/websearch',
        routes: {
          '/websearch': (context) => webSearchDemo,
          '/imagesearch': (context) => CustomImageSearchDemo(),
        },
        title: 'Custom Search Engine Flutter Demo');
  }
}
