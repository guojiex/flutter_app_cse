import 'package:flutter/material.dart';

@immutable
class NoResultCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new Text('No Result.'),
    );
  }
}

Widget noResultCardInContainer(BuildContext context) {
  return GridView.count(
    crossAxisCount: 1,
    mainAxisSpacing: 4.0,
    crossAxisSpacing: 4.0,
    padding: const EdgeInsets.all(4.0),
    children: [new NoResultCard()],
  );
}