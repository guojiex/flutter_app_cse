import 'package:flutter/material.dart';
import 'package:flutter_app_cse/search_data_source.dart';

import 'ui/no_result_card.dart';
import 'ui/web_search_result_card.dart';
import 'ui/image_search_result_card.dart';
import 'ui/pagination_tab.dart';
import 'shared_constant.dart';

class CustomSearchSearchDelegate extends SearchDelegate<SearchResult> {
  SearchDataSource dataSource;
  AutoCompleteDataSource autoCompleteDataSource;
  SearchType searchType;

  CustomSearchSearchDelegate(
      {this.dataSource,
      this.autoCompleteDataSource =
          const CommonEnglishWordAutoCompleteDataSource(),
      this.searchType = SearchType.web});

  CustomSearchSearchDelegate.imageSearch(
      {this.dataSource,
      this.autoCompleteDataSource =
          const CommonEnglishWordAutoCompleteDataSource(),
      this.searchType = SearchType.image});

  CustomSearchSearchDelegate.fakeStaticSource() {
    this.dataSource = FakeSearchDataSource();
    this.searchType = SearchType.web;
    this.autoCompleteDataSource =
        const CommonEnglishWordAutoCompleteDataSource();
  }

  CustomSearchSearchDelegate.fakeStaticSourceImageSearch() {
    this.dataSource = FakeSearchDataSource();
    this.searchType = SearchType.image;
    this.autoCompleteDataSource =
        const CommonEnglishWordAutoCompleteDataSource();
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
                close(context, null);
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

  Widget buildResultsFromQuery(BuildContext context, SearchQuery searchQuery) {
    return FutureBuilder<SearchResults>(
      future: dataSource.search(searchQuery),
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
                    children: List.generate(
                        snapshot.data.searchResults.length + 2, (index) {
                      if (index == snapshot.data.searchResults.length) {
                        return Container(
                          child: PaginationTab.nextPage(() {
                            this.buildResultsFromQuery(
                                context, snapshot.data.nextPage);
                          }),
                        );
                      }
                      if (index == snapshot.data.searchResults.length + 1) {
                        return PaginationTab.previousPage(() {});
                      }
                      return new ImageSearchResultCard(
                          searchResult: snapshot.data.searchResults[index]);
                    }));

              case SearchType.web:
                return ListView.builder(
                    itemCount: snapshot.data.searchResults.length + 2,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == snapshot.data.searchResults.length) {
                        return PaginationTab.nextPage(() {
                          this.buildResultsFromQuery(
                              context, snapshot.data.nextPage);
                        });
                      }
                      if (index == snapshot.data.searchResults.length + 1) {
                        return PaginationTab.previousPage(() {});
                      }
                      return WebSearchResultCard(
                          searchResult: snapshot.data.searchResults[index]);
                    });
              default:
                print('should not reach here!');
            }
        }
        return null; // unreachable
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return this.buildResultsFromQuery(
        context,
        SearchQuery(query, dataSource.cx,
            searchType: this.searchType == SearchType.web ? null : 'image'));
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
