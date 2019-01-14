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
          // When we navigate to the "/cse/websearch" route, build the FirstScreen Widget
          '/websearch': (context) => CustomWebSearchDemo(),
          // When we navigate to the "/cse/imagesearch" route, build the SecondScreen Widget
          '/imagesearch': (context) => CustomImageSearchDemo(),
        },
        title: 'Custom Search Engine Flutter Demo');
  }
}
