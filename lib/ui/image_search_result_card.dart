import 'package:flutter/material.dart';
import 'package:flutter_app_cse/search_data_source.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

/// Result card for iamge search. Will try to load image. If failed, fall back to
/// try thumbnail image.
class ImageSearchResultCard extends StatelessWidget {
  ImageSearchResultCard({@required this.searchResult});

  final SearchResult searchResult;

  Widget buildGridTileWithImage(BuildContext context, Uint8List imageData) {
    return GridTile(
        child: Image.memory(imageData, fit: BoxFit.cover),
        footer: GridTileBar(
            backgroundColor: Colors.black45,
            title: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(this.searchResult.result.title),
            )));
  }

  Widget buildGridTileWithThumbnailLink(BuildContext context,
      String thumbnailLink) {
    return GridTile(
        child: Image.network(thumbnailLink, fit: BoxFit.cover),
        footer: GridTileBar(
            backgroundColor: Colors.black45,
            title: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(this.searchResult.result.title),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: http.get(this.searchResult.result.link),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 2,
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: CircularProgressIndicator(),
                  )),
            );
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return GestureDetector(
              onTap: () async {
                if (await canLaunch(searchResult.result.image.contextLink)) {
                  await launch(searchResult.result.image.contextLink);
                }
              },
              child: snapshot.data.statusCode == 200
                  ? buildGridTileWithImage(context, snapshot.data.bodyBytes)
                  : buildGridTileWithThumbnailLink(
                  context, searchResult.result.image.thumbnailLink),
            );
        }
      },
    );
  }
}
