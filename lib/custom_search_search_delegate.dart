import 'package:flutter/material.dart';
import 'package:flutter_app_cse/search_data_source.dart';

import 'ui/no_result_card.dart';
import 'ui/web_search_result_card.dart';
import 'ui/image_search_result_card.dart';
import 'ui/pagination_tab.dart';
import 'shared_constant.dart';

/// A [SearchDelegate] for search using CSE API.
///
/// Please use [CustomSearchInfiniteSearchDelegate] until the nextPage/previousPage
/// TODO is done.
/// TODO: Complete the nextPage/previousPage button with callback.
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

  Widget buildResultPage(BuildContext context, SearchResults searchResults) {
    if (searchResults.searchResults.isEmpty) {
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
            children:
            List.generate(searchResults.searchResults.length + 2, (index) {
              if (index == searchResults.searchResults.length) {
                return Container(
                  child: PaginationTab.nextPage(() {
                    // TODO: Fillin the callback.
                  }),
                );
              }
              if (index == searchResults.searchResults.length + 1) {
                return PaginationTab.previousPage(() {
                  // TODO: Fillin the callback.
                });
              }
              return new ImageSearchResultCard(
                  searchResult: searchResults.searchResults[index]);
            }));

      case SearchType.web:
        return ListView.builder(
            itemCount: searchResults.searchResults.length + 2,
            itemBuilder: (BuildContext context, int index) {
              if (index == searchResults.searchResults.length) {
                return PaginationTab.nextPage(() {
                  // TODO: Fillin the callback.
                });
              }
              if (index == searchResults.searchResults.length + 1) {
                return PaginationTab.previousPage(() {
                  // TODO: Fillin the callback.
                });
              }
              return WebSearchResultCard(
                  searchResult: searchResults.searchResults[index]);
            });
      default:
        print('should not reach here!');
    }
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
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            print('done');
            return buildResultPage(context, snapshot.data);
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

class KeepAliveFutureBuilder extends StatefulWidget {
  final Future future;
  final AsyncWidgetBuilder builder;

  KeepAliveFutureBuilder({this.future, this.builder});

  @override
  _KeepAliveFutureBuilderState createState() => _KeepAliveFutureBuilderState();
}

class _KeepAliveFutureBuilderState extends State<KeepAliveFutureBuilder>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.future,
      builder: widget.builder,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

/// A SearchDelegate that will render the result page as infinite scroll view.
class CustomSearchInfiniteSearchDelegate extends CustomSearchSearchDelegate {
  CustomSearchInfiniteSearchDelegate({dataSource,
    autoCompleteDataSource = const CommonEnglishWordAutoCompleteDataSource(),
    searchType = SearchType.web})
      : super(
      dataSource: dataSource,
      autoCompleteDataSource: autoCompleteDataSource,
      searchType: searchType);

  CustomSearchInfiniteSearchDelegate.imageSearch({dataSource,
    autoCompleteDataSource = const CommonEnglishWordAutoCompleteDataSource(),
    searchType = SearchType.image})
      : super.imageSearch(
      dataSource: dataSource,
      autoCompleteDataSource: autoCompleteDataSource,
      searchType: searchType);

  CustomSearchInfiniteSearchDelegate.fakeStaticSource()
      : super.fakeStaticSource();

  CustomSearchInfiniteSearchDelegate.fakeStaticSourceImageSearch()
      : super.fakeStaticSourceImageSearch();

  Widget _buildWebSearchResultPage(SearchResults searchResults) {
    return ListView(
        shrinkWrap: true,
        primary: false,
        children: searchResults.searchResults.map((searchResult) {
          return WebSearchResultCard(searchResult: searchResult);
        }).toList());
  }

  Widget _buildImageSearchResultPage(SearchResults searchResults) {
    return GridView.builder(
        shrinkWrap: true,
        primary: false,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
        ),
        itemCount: searchResults.searchResults.length,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return ImageSearchResultCard(
              searchResult: searchResults.searchResults[index]);
        });
  }

  /// A cached searchresults, for nextPage usage.
  SearchResults currentSearchResults;

  @override
  void close(BuildContext context, SearchResult result) {
    this.currentSearchResults = null;
    super.close(context, result);
  }

  @override
  Widget buildResultsFromQuery(BuildContext context, SearchQuery searchQuery) {
    switch (this.searchType) {
      case SearchType.image:
        return FutureBuilder(
            future: this.currentSearchResults == null
                ? dataSource.search(searchQuery)
                : dataSource.search(currentSearchResults.nextPage),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text('Press button to start.');
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
                  } else {
                    this.currentSearchResults = snapshot.data;
                    return _buildImageSearchResultPage(snapshot.data);
                  }
              }
            });
      case SearchType.web:
        return ListView.builder(
            itemCount:
            99, // Custom Search API will not return more than 100 results.
            itemBuilder: (BuildContext context, int index) {
              return FutureBuilder(
                future: this.currentSearchResults == null
                    ? dataSource.search(searchQuery)
                    : dataSource.search(currentSearchResults.nextPage),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return Text('Press button to start.');
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
                      } else {
                        this.currentSearchResults = snapshot.data;
                        return _buildWebSearchResultPage(snapshot.data);
                      }
                  }
                },
              );
            });
    }
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
