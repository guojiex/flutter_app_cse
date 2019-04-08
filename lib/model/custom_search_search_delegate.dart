import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app_cse/model/search_data_source.dart';

import '../ui/mix_search_result_page.dart';
import '../ui/web_search_result_page.dart';
import '../ui/no_result_card.dart';
import '../ui/web_search_result_card.dart';
import '../ui/image_search_result_card.dart';
import '../ui/pagination_tab.dart';
import '../ui/image_search_result_page.dart';
import '../ui/loading_progress_indicator.dart';
import '../shared_constant.dart';

/// A [SearchDelegate] for search using CSE API.
///
/// Please use [CustomSearchInfiniteSearchDelegate] until the nextPage/previousPage
/// TODO is done.
/// TODO: Complete the nextPage/previousPage button with callback.
class CustomSearchSearchDelegate extends SearchDelegate<SearchResult> {
  SearchDataSource dataSource;
  AutoCompleteDataSource autoCompleteDataSource;
  SearchResultPageType searchResultPageType;

  CustomSearchSearchDelegate(
      {this.dataSource,
      this.autoCompleteDataSource =
          const CommonEnglishWordAutoCompleteDataSource(),
        this.searchResultPageType = SearchResultPageType.web});

  CustomSearchSearchDelegate.imageSearch(
      {this.dataSource,
      this.autoCompleteDataSource =
          const CommonEnglishWordAutoCompleteDataSource(),
        this.searchResultPageType = SearchResultPageType.image});

  CustomSearchSearchDelegate.fakeStaticSource() {
    this.dataSource = FakeSearchDataSource();
    this.searchResultPageType = SearchResultPageType.web;
    this.autoCompleteDataSource =
        const CommonEnglishWordAutoCompleteDataSource();
  }

  CustomSearchSearchDelegate.fakeStaticSourceImageSearch() {
    this.dataSource = FakeSearchDataSource();
    this.searchResultPageType = SearchResultPageType.image;
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
      return noResultCardInContainer(context);
    }
    switch (this.searchResultPageType) {
      case SearchResultPageType.image:
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

      case SearchResultPageType.web:
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
      builder: (BuildContext context, AsyncSnapshot<SearchResults> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('Press button to start.');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return loadingProgressIndicator(context);
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
            searchType: this.searchResultPageType == SearchResultPageType.image
                ? 'image'
                : null));
  }
}

/// A SearchDelegate that will render the result page as infinite scroll view.
class CustomSearchInfiniteSearchDelegate extends CustomSearchSearchDelegate {
  CustomSearchInfiniteSearchDelegate({dataSource,
    autoCompleteDataSource = const CommonEnglishWordAutoCompleteDataSource(),
    searchType = SearchResultPageType.web})
      : super(
      dataSource: dataSource,
      autoCompleteDataSource: autoCompleteDataSource,
      searchResultPageType: searchType);

  CustomSearchInfiniteSearchDelegate.imageSearch({dataSource,
    autoCompleteDataSource = const CommonEnglishWordAutoCompleteDataSource(),
    searchType = SearchResultPageType.image})
      : super.imageSearch(
      dataSource: dataSource,
      autoCompleteDataSource: autoCompleteDataSource,
      searchResultPageType: searchType);

  CustomSearchInfiniteSearchDelegate.mixSearch({dataSource,
    autoCompleteDataSource = const CommonEnglishWordAutoCompleteDataSource(),
    searchType = SearchResultPageType.mix})
      : super(
      dataSource: dataSource,
      autoCompleteDataSource: autoCompleteDataSource,
      searchResultPageType: searchType);

  CustomSearchInfiniteSearchDelegate.fakeStaticSource()
      : super.fakeStaticSource();

  CustomSearchInfiniteSearchDelegate.fakeStaticSourceImageSearch()
      : super.fakeStaticSourceImageSearch();

  Widget _buildSearchResultPage(BuildContext context, SearchQuery searchQuery) {
    print(searchQuery);
    return FutureBuilder(
      future: dataSource.search(searchQuery),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('Press button to start.');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return loadingProgressIndicator(context);
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.data.searchResults.isEmpty) {
              return noResultCardInContainer(context);
            }
            switch (this.searchResultPageType) {
              case SearchResultPageType.image:
                return ImageSearchResultPage(
                    dataSource, snapshot.data, searchQuery);
              case SearchResultPageType.web:
                return WebSearchResultPage(
                    dataSource, snapshot.data, searchQuery);
              case SearchResultPageType.mix:
                return MixSearchResultPage(
                    dataSource, snapshot.data, searchQuery);
            }
        }
      },
    );
  }

  @override
  Widget buildResultsFromQuery(BuildContext context, SearchQuery searchQuery) {
    return _buildSearchResultPage(context, searchQuery);
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
