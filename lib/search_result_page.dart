import 'package:flutter/material.dart';
import 'package:flutter_app_cse/search_data_source.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({this.searchResult, this.searchDelegate});

  final SearchResult searchResult;
  final SearchDelegate<SearchResult> searchDelegate;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new GestureDetector(
      onTap: () async {
        if (await canLaunch(searchResult.result.link)) {
          await launch(searchResult.result.link);
        }
      },
      child: new Card(
        child: new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new ListTile(
            leading: new Image.network(
                this.searchResult.result.pagemap['thumbnail'][0]['src']),
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
        ),
      ),
    );
  }
}

class FakeJsonSearchDelegate extends SearchDelegate<SearchResult> {
  FakeSearchDataSource _dataSource = FakeSearchDataSource('');
  FakeAutoCompleteDataSource _autoCompleteDataSource =
  FakeAutoCompleteDataSource();

  FakeJsonSearchDelegate() {
    _dataSource.initFromAsset();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _SuggestionList(
      suggestions: _autoCompleteDataSource.getAutoCompletions(query: query),
      query: query,
      onSelected: (String suggestion) {
        query = suggestion;
        showResults(context);
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      query.isEmpty
          ? new IconButton(
        tooltip: 'Voice Search',
        icon: const Icon(Icons.mic),
        onPressed: () {
          query = 'TODO: implement voice input';
        },
      )
          : new IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () async {
          await showSearch<SearchResult>(
            context: context,
            delegate: this,
          );
        },
      )
    ];
  }

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
      future: _dataSource.search(
          query), // a previously-obtained Future<List<SearchResult>> or null
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
                itemBuilder: (BuildContext context, int index) {
                  return new ResultCard(
                      searchResult: snapshot.data[index], searchDelegate: this);
                });
        }
        return null; // unreachable
      },
    );
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({this.suggestions, this.query, this.onSelected});

  final List<String> suggestions;
  final String query;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int i) {
        final String suggestion = suggestions[i];
        return new ListTile(
          leading: query.isEmpty ? const Icon(Icons.history) : const Icon(null),
          title: new RichText(
            text: new TextSpan(
              text: suggestion.substring(0, query.length),
              style:
              theme.textTheme.subhead.copyWith(fontWeight: FontWeight.bold),
              children: <TextSpan>[
                new TextSpan(
                  text: suggestion.substring(query.length),
                  style: theme.textTheme.subhead,
                ),
              ],
            ),
          ),
          onTap: () {
            onSelected(suggestion);
          },
        );
      },
    );
  }
}
