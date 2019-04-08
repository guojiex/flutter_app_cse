import 'package:flutter/material.dart';
import 'package:flutter_app_cse/model/search_data_source.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

import 'loading_progress_indicator.dart';

/// Result card for image search. Will try to load image. If failed, fall back to
/// try thumbnail image.
class ImageSearchResultCard extends StatelessWidget {
  ImageSearchResultCard({@required this.searchResult});

  final SearchResult searchResult;

  Widget _buildGridTileWithImage(BuildContext context, Uint8List imageData) {
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

  Widget _buildGridTileWithThumbnailLink(BuildContext context,
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
            return loadingProgressIndicator(context);
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
                  ? _buildGridTileWithImage(context, snapshot.data.bodyBytes)
                  : _buildGridTileWithThumbnailLink(
                  context, searchResult.result.image.thumbnailLink),
            );
        }
      },
    );
  }
}
