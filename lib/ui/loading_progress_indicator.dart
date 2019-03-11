import 'package:flutter/material.dart';

Widget loadingProgressIndicator(BuildContext context) {
  return SizedBox(
    height: MediaQuery.of(context).size.height * 2,
    child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: 5.0),
          child: CircularProgressIndicator(),
        )),
  );
}
