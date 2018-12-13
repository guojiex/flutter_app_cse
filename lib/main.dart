import 'package:flutter/material.dart';
import 'package:flutter_app_cse/search_bar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Search Engine Flutter Demo',
      home: Scaffold(
        appBar: new AppBar(title: new SearchBar()),
      ),
    );
  }
}
