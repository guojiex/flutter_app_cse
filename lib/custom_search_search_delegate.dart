import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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

  /// A cached [SearchResults], for nextPage usage.
  SearchResults currentSearchResults;
  int currentResultLength = 0;

  @override
  void close(BuildContext context, SearchResult result) {
    this.currentSearchResults = null;
    this.currentResultLength = 0;
    this.refinementBar = null;
    super.close(context, result);
  }

  _loadNextPage() {
    dataSource.search(currentSearchResults.nextPage).then((value) {
      this.currentSearchResults = value;
      this.currentResultLength +=
          this.currentSearchResults.searchResults.length;
      debugPrint(
          'current result length ${this.currentSearchResults.searchResults
              .length}');
    });
  }

  Widget _buildImageGridPage(BuildContext context, SearchQuery searchQuery) {
    return GridView.builder(
        shrinkWrap: true,
        primary: false,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
        ),
        itemCount: 99,
        itemBuilder: (_, index) {
          if (this.currentSearchResults == null) {
            return FutureBuilder(
                future: dataSource.search(searchQuery),
                builder: (context, snapshot) {
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
                      this.currentSearchResults = snapshot.data;
                      return ImageSearchResultCard(
                          searchResult: this.currentSearchResults.searchResults[
                              index %
                                  this
                                      .currentSearchResults
                                      .searchResults
                                      .length]);
                  }
                });
          }
          if (index >= currentResultLength) {
            this._loadNextPage();
          }
          return ImageSearchResultCard(
              searchResult: this.currentSearchResults.searchResults[
                  index % this.currentSearchResults.searchResults.length]);
        });
  }

  Widget _buildFloatingRefinementButtons(BuildContext context,
      SearchResults searchResults) {
    return Container(
      height: 20.0,
      child: Row(
          children: [
            Expanded(
                flex: 1,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    print('All button click');
                  },
                  icon: new Icon(
                    Icons.flag,
                  ),
                  label: new Text('All', maxLines: 1),
                ))
          ] +
              searchResults.refinements.map((refinement) {
                return Expanded(
                    flex: 1,
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        print('${refinement.label} button click');
                      },
                      icon: new Icon(
                        Icons.flag,
                      ),
                      label: new Text(refinement.label, maxLines: 1),
                    ));
              }).toList()),
    );
  }

  Widget refinementBar;

  Widget _buildWebSearchResultSubList(SearchResults searchResults,
      Widget injectedBar) {
    if (injectedBar != null) {
      return Column(
        children: <Widget>[
          injectedBar,
          ListView(
              shrinkWrap: true,
              primary: false,
              children: searchResults.searchResults.map((searchResult) {
                return WebSearchResultCard(searchResult: searchResult);
              }).toList())
        ],
      );
    } else {
      return ListView(
          shrinkWrap: true,
          primary: false,
          children: searchResults.searchResults.map((searchResult) {
            return WebSearchResultCard(searchResult: searchResult);
          }).toList());
    }
  }

  Widget _buildWebListPage(BuildContext context, SearchQuery searchQuery) {
    return ListView.builder(
        itemCount:
        9, // Custom Search API will not return more than 100 results.
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
                  }
                  this.currentSearchResults = snapshot.data;
                  if (!snapshot.data.refinements.isEmpty) {
                    if (this.refinementBar == null) {
                      this.refinementBar = _buildFloatingRefinementButtons(
                          context, snapshot.data);
                    }
                  }
                  return _buildWebSearchResultSubList(
                      snapshot.data, this.refinementBar);
              }
            },
          );
        });
  }

  @override
  Widget buildResultsFromQuery(BuildContext context, SearchQuery searchQuery) {
    switch (this.searchType) {
      case SearchType.image:
        return _buildImageGridPage(context, searchQuery);
      case SearchType.web:
        return _buildWebListPage(context, searchQuery);
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
