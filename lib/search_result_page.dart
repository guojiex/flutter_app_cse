import 'package:flutter/material.dart';
import 'package:flutter_app_cse/search_data_source.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({this.searchResult, this.searchDelegate});

  final SearchResult searchResult;
  final SearchDelegate<SearchResult> searchDelegate;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new GestureDetector(
      onTap: () {
        searchDelegate.close(context, searchResult);
      },
      child: new Card(
        child: new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Column(
            children: <Widget>[
              new Text(this.searchResult.result.htmlTitle),
              new Text(
                this.searchResult.result.htmlSnippet,
                style: theme.textTheme.headline.copyWith(fontSize: 72.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FakeJsonSearchDelegate extends SearchDelegate<SearchResult> {
  FakeSearchDataSource _datasource = FakeSearchDataSource('');

  FakeJsonSearchDelegate() {
    _datasource.initFromAsset();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return null;
  }

  @override
  List<Widget> buildActions(BuildContext context) {}

  @override
  Widget buildLeading(BuildContext context) {
    return new IconButton(
      tooltip: 'Back',
      icon: new AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<SearchResult>>(
      future: _datasource.search(
          'query'), // a previously-obtained Future<List<SearchResult>> or null
      builder:
          (BuildContext context, AsyncSnapshot<List<SearchResult>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('Press button to start.');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Text('Awaiting result...');
          case ConnectionState.done:
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return new ResultCard(
                      searchResult: snapshot.data[index], searchDelegate: this);
                });
        }
        return null; // unreachable
      },
    );
  }
}
