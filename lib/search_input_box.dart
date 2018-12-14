import 'package:flutter/material.dart';

/// A Search Input Box that are mainly designed for [Custom Search Engine](https://cse.google.com).
class SearchInputBox extends StatefulWidget {
  final String startSearchValue;
  final bool enablePrefixIcon;
  @override
  _SearchInputBoxState createState() =>
      _SearchInputBoxState(this.enablePrefixIcon, this.startSearchValue);

  SearchInputBox(
      {this.enablePrefixIcon = true,
      this.startSearchValue = 'Google Custom Search'});
}

class _SearchInputBoxState extends State<SearchInputBox> {
  final bool enablePrefixIcon;
  final String startSearchValue;
  FocusNode _textFieldFocusNode;
  TextEditingController _searchInputBoxController;

  _SearchInputBoxState(this.enablePrefixIcon, this.startSearchValue);

  @override
  void initState() {
    super.initState();
    this._textFieldFocusNode = FocusNode();
    print(this._textFieldFocusNode);
    this._searchInputBoxController = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    this._searchInputBoxController.dispose();
    this._textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(this._textFieldFocusNode);
    return new Row(
      children: <Widget>[
        this.enablePrefixIcon
            ? new Padding(
                padding: EdgeInsets.only(right: 25),
                child: new IconButton(
                    icon: Icon(Icons.search),
                    tooltip: 'Click to focus on the text edit field.',
                    onPressed: () {
                      FocusScope.of(context)
                          .requestFocus(this._textFieldFocusNode);
                    }),
              )
            : null,
        new Expanded(
          child: new TextField(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: startSearchValue,
            ),
            controller: this._searchInputBoxController,
            textInputAction: TextInputAction.search,
            focusNode: this._textFieldFocusNode,
          ),
        ),
      ].where((item) => item != null).toList(),
    );
  }
}