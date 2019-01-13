import 'package:flutter/material.dart';
import 'package:flutter_app_cse/CustomWebSearchDemo.dart';

void main() => runApp(SearchDemoApp());

class SearchDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: CustomWebSearchDemo(),
        title: 'Custom Search Engine Flutter Demo');
  }
}
