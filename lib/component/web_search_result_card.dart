import 'package:flutter/material.dart';
import 'package:flutter_app_cse/shared_constant.dart';
import 'package:flutter_app_cse/search_data_source.dart';
import 'package:url_launcher/url_launcher.dart';

class WebSearchResultCard extends StatelessWidget {
  const WebSearchResultCard(
      {@required this.searchResult,
      this.webSearchLayout = WebSearchLayout.CSE});

  final SearchResult searchResult;
  final WebSearchLayout webSearchLayout;

  Widget _generateTitleTile(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListTile(
      title: Padding(
        padding: EdgeInsets.only(top: 6.0),
        child: Text(
          this.searchResult.result.title,
          style: theme.textTheme.headline.copyWith(
              fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ),
      subtitle: new Text(
        this.searchResult.result.link,
        style:
            theme.textTheme.body1.copyWith(fontSize: 14.0, color: Colors.green),
      ),
    );
  }

  Widget _generateBodyTile(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    bool haveThumbnail = this.searchResult.result.pagemap['thumbnail'] != null;
    if (!haveThumbnail) {
      return Container(
        padding: const EdgeInsets.only(
          left: 14.0,
          bottom: 8.0,
        ),
        child: Container(
            padding: const EdgeInsets.only(right: 10.0),
            child: Text(
              this.searchResult.result.snippet,
              style: theme.textTheme.body1,
              textAlign: TextAlign.left,
            )),
      );
    } else {
      return Container(
        padding: const EdgeInsets.only(
          left: 15.0,
          bottom: 8.0,
        ),
        child: new Row(children: [
          Image.network(
              this.searchResult.result.pagemap['thumbnail'][0]['src']),
          Expanded(
              child: Container(
                  padding: const EdgeInsets.only(left: 10.0, right: 12.0),
                  child: Text(
                    this.searchResult.result.snippet,
                    style: theme.textTheme.body1,
                    textAlign: TextAlign.left,
                  ))),
        ]),
      );
    }
  }

  Widget _buildSimpleLayout(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new Card(
        child: new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new ListTile(
        leading: this.searchResult.result.pagemap['thumbnail'] != null
            ? new Image.network(
                this.searchResult.result.pagemap['thumbnail'][0]['src'])
            : null,
        title: new Text(
          this.searchResult.result.title,
          style: theme.textTheme.headline
              .copyWith(fontSize: 12.0, fontWeight: FontWeight.bold),
        ),
        subtitle: new Text(
          this.searchResult.result.snippet,
          style: theme.textTheme.body1.copyWith(fontSize: 12.0),
        ),
      ),
    ));
  }

  Widget _buildCSELayout(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(boxShadow: [
        new BoxShadow(
          color: Colors.grey,
          blurRadius: 1.0,
        ),
      ]),
      child: new Card(
        child: Column(
          children: [
            _generateTitleTile(context),
            new Divider(color: Colors.black26),
            _generateBodyTile(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFromLayout(BuildContext context) {
    switch (this.webSearchLayout) {
      case WebSearchLayout.simple:
        return _buildSimpleLayout(context);
      case WebSearchLayout.CSE:
        return _buildCSELayout(context);
      default:
        return new Text('Invalid Layout For WebSearchResult!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
        onTap: () async {
          if (await canLaunch(searchResult.result.link)) {
            await launch(searchResult.result.link);
          }
        },
        child: _buildFromLayout(context));
  }
}
