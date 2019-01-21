import 'package:flutter/material.dart';
import 'package:flutter_app_cse/search_data_source.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageSearchResultCard extends StatelessWidget {
  ImageSearchResultCard({this.searchResult, this.searchDelegate});

  final SearchResult searchResult;
  final SearchDelegate<SearchResult> searchDelegate;

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

class WebSearchResultCard extends StatelessWidget {
  const WebSearchResultCard({this.searchResult,
    this.searchDelegate,
    this.webSearchLayout = WebSearchLayout.CSE});

  final SearchResult searchResult;
  final SearchDelegate<SearchResult> searchDelegate;
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

class NoResultCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new Text('No Result.'),
    );
  }
}

enum SearchType { web, image }
enum WebSearchLayout { simple, CSE }

class CustomSearchSearchDelegate extends SearchDelegate<SearchResult> {
  SearchDataSource dataSource;
  AutoCompleteDataSource autoCompleteDataSource =
  CommonEnglishWordAutoCompleteDataSource();
  SearchType searchType;

  CustomSearchSearchDelegate(
      {this.dataSource,
      this.autoCompleteDataSource,
      this.searchType = SearchType.web});

  CustomSearchSearchDelegate.imageSearch(
      {this.dataSource,
        this.autoCompleteDataSource,
        this.searchType = SearchType.image});

  CustomSearchSearchDelegate.fakeStaticSource() {
    this.dataSource = FakeSearchDataSource();
    this.searchType = SearchType.web;
  }
  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
        inputDecorationTheme: InputDecorationTheme(
            hintStyle: TextStyle(color: theme.primaryTextTheme.title.color)),
        primaryColor: theme.primaryColor,
        primaryIconTheme: theme.primaryIconTheme,
        primaryColorBrightness: theme.primaryColorBrightness,
        primaryTextTheme: theme.primaryTextTheme,
        textTheme: theme.textTheme.copyWith(
            title: theme.textTheme.title
                .copyWith(color: theme.primaryTextTheme.title.color)));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _SuggestionList(
      suggestions: autoCompleteDataSource.getAutoCompletions(query: query),
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
    return FutureBuilder<SearchResults>(
      future: dataSource.search(query,
          searchType: this.searchType == SearchType.web ? null : 'image'),
      // a previously-obtained Future<List<SearchResult>> or null
      builder: (BuildContext context, AsyncSnapshot<SearchResults> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('Press button to start.');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Text('Awaiting result...');
          case ConnectionState.done:
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            if (snapshot.data.searchResults.isEmpty) {
              return GridView.count(
                crossAxisCount: 1,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
                padding: const EdgeInsets.all(4.0),
                children: [new NoResultCard()],
              );
            }
            switch (this.searchType) {
              case SearchType.image:
                return GridView.count(
                    crossAxisCount: 1,
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                    padding: const EdgeInsets.all(4.0),
                    children: List.generate(snapshot.data.searchResults.length,
                            (index) {
                          return new ImageSearchResultCard(
                              searchResult: snapshot.data.searchResults[index],
                              searchDelegate: this);
                        }));
              case SearchType.web:
                return ListView.builder(
                    itemCount: snapshot.data.searchResults.length,
                    itemBuilder: (BuildContext context, int index) {
                      return new WebSearchResultCard(
                          searchResult: snapshot.data.searchResults[index],
                          searchDelegate: this);
                    });
              default:
                print('should not reach here!');
            }
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
