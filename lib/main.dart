import 'package:flutter/material.dart';
import 'package:flutter_app_cse/search_input_box.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Search Engine Flutter Demo',
      home: Scaffold(
        appBar: new AppBar(
          leading: new Icon(Icons.search),
          title: new SearchInputBox(),
        ),
      ),
    );
  }
}
