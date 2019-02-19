import 'package:flutter/material.dart';
import 'package:flutter_app_cse/shared_constant.dart';

class PaginationTab extends StatelessWidget {
  final PaginationTabType paginationTabType;
  final Function onTapCallback;

  PaginationTab.nextPage(this.onTapCallback)
      : paginationTabType = PaginationTabType.nextPage;

  PaginationTab.previousPage(this.onTapCallback)
      : paginationTabType = PaginationTabType.previousPage;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
        decoration: new BoxDecoration(boxShadow: [
          new BoxShadow(
            color: Colors.grey,
            blurRadius: 1.0,
          ),
        ]),
        child: GestureDetector(
            onTap: () {
              onTapCallback();
            },
            child: new Card(
                child: new ListTile(
                    title: Row(
                      children: paginationTabType == PaginationTabType.nextPage
                          ? <Widget>[
                        new Text(
                          '       Next Page',
                          style: theme.textTheme.headline.copyWith(
                              fontSize: 15.0, fontWeight: FontWeight.bold),
                        ),
                        new Icon(Icons.arrow_right)
                      ]
                          : <Widget>[
                        Icon(Icons.arrow_left),
                        Text(
                          'Previous Page',
                          style: theme.textTheme.headline.copyWith(
                              fontSize: 15.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    )))));
  }
}
