import 'package:flutter/material.dart';
import 'package:flutter_app_cse/search_data_source.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageSearchResultCard extends StatelessWidget {
  ImageSearchResultCard({@required this.searchResult});

  final SearchResult searchResult;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (await canLaunch(searchResult.result.image.contextLink)) {
          await launch(searchResult.result.image.contextLink);
        }
      },
      child: GridTile(
        child: Image.network(this.searchResult.result.link, fit: BoxFit.cover),
        footer: GridTileBar(
            backgroundColor: Colors.black45,
            title: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(this.searchResult.result.title),
            )),
      ),
    );
  }
}
