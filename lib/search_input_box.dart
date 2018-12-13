import 'package:flutter/material.dart';

class SearchInputBox extends StatefulWidget {
  @override
  _SearchInputBoxState createState() => _SearchInputBoxState();
}

class _SearchInputBoxState extends State<SearchInputBox> {
  // Create a text controller. We will use it to retrieve the current value
  // of the TextField!
  static final String startSearchValue = 'Google Custom Search';
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Expanded(
          child: new TextField(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: startSearchValue,
            ),
            controller: myController,
            textInputAction: TextInputAction.search,
          ),
        ),
      ],
    );
  }
}
