import 'package:flutter/material.dart';

class SearchInputBox extends StatefulWidget {
  @override
  _SearchInputBoxState createState() => _SearchInputBoxState();
}

class _SearchInputBoxState extends State<SearchInputBox> {
  // Create a text controller. We will use it to retrieve the current value
  // of the TextField!
  static final String startSearchValue = 'Click to start search';
  final myController = TextEditingController(text: startSearchValue);
  bool startTyping = false;

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Row(
      children: <Widget>[
        new Expanded(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: myController,
                onTap: () {
                  if (!startTyping) {
                    myController.clear();
                    startTyping = true;
                  }
                },
                onSubmitted: (text) {
                  if (text.isEmpty) {
                    startTyping = false;
                    myController.text = startSearchValue;
                  }
                },
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
