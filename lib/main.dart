import 'package:flutter/material.dart';
import 'package:flutter_app_cse/CustomWebSearchPage.dart';
import 'package:flutter_app_cse/CustomImageSearchPage.dart';

void main() => runApp(SearchDemoApp());

class SearchDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: CustomWebSearchDemo(),
        initialRoute: '/websearch',
        routes: {
          '/websearch': (context) => CustomWebSearchDemo(),
          '/imagesearch': (context) => CustomImageSearchDemo(),
        },
        title: 'Custom Search Engine Flutter Demo');
  }
}
