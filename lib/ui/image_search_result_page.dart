import 'package:flutter/material.dart';

import '../search_data_source.dart';
import 'no_result_card.dart';
import 'image_search_result_card.dart';
import 'loading_progress_indicator.dart';

class ImageSearchResultPage extends StatefulWidget {
  final SearchDataSource dataSource;
  final SearchResults initialSearchResult;
  SearchQuery searchQuery;
  final Refinement currentRefinement;
  final bool withRefinementTabBar;

  ImageSearchResultPage(
      this.dataSource, this.initialSearchResult, this.searchQuery,
      {this.currentRefinement, this.withRefinementTabBar = true}) {
    this.searchQuery = this.searchQuery.copyWith(searchType: 'image');
  }

  @override
  _ImageSearchResultPageState createState() =>
      new _ImageSearchResultPageState(initialSearchResult);
}

class _ImageSearchResultPageState extends State<ImageSearchResultPage>
    with SingleTickerProviderStateMixin {
  SearchResults initialSearchResult;
  SearchResults currentSearchResults;
  TabController _tabController;
  List<Tab> _refinementTabs = new List<Tab>();
  int currentResultLength = 0;

  _ImageSearchResultPageState(this.initialSearchResult) {
    if (initialSearchResult.refinements.isNotEmpty) {
      _refinementTabs.add(Tab(text: 'all'));
      initialSearchResult.refinements.forEach(
          (refinement) => _refinementTabs.add(Tab(text: refinement.label)));
      _tabController =
          TabController(vsync: this, length: _refinementTabs.length);
    }
  }

  @override
  void dispose() {
    currentSearchResults = null;
    this.currentSearchResults = null;
    this._refinementTabs.clear();
    _tabController?.dispose();
    super.dispose();
  }

  _loadNextPage() {
    widget.dataSource.search(currentSearchResults.nextPage).then((value) {
      this.currentSearchResults = value;
      this.currentResultLength +=
          this.currentSearchResults.searchResults.length;
      debugPrint(
          'current result length ${this.currentSearchResults.searchResults.length}');
    });
  }

  Widget _buildImageGridPage(BuildContext context) {
    return GridView.builder(
        shrinkWrap: true,
        primary: false,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
        ),
        itemCount: 99,
        itemBuilder: (_, index) {
          if (index == 0) {
            this.currentSearchResults = initialSearchResult;
            currentResultLength +=
                this.currentSearchResults.searchResults.length;
            if (currentSearchResults.searchResults.isEmpty) {
              return noResultCardInContainer(context);
            }
          }
          if (index >= currentResultLength) {
            this._loadNextPage();
          }
          return ImageSearchResultCard(
              searchResult: this.currentSearchResults.searchResults[
                  index % this.currentSearchResults.searchResults.length]);
        });
  }

  @override
  Widget build(BuildContext context) {
    if (this._refinementTabs.isEmpty || !widget.withRefinementTabBar) {
      return _buildImageGridPage(context);
    }
    if (widget.withRefinementTabBar) {
      return Scaffold(
          appBar: new PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight - 8),
            child: new Container(
              color: Colors.blue,
              child: new SafeArea(
                child: Column(
                  children: <Widget>[
                    new TabBar(
                      isScrollable: true,
                      controller: _tabController,
                      tabs: _refinementTabs,
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: _refinementTabs.map((Tab tab) {
              if (tab.text == 'all') {
                return _buildImageGridPage(context);
              } else {
                final currentRefinement = initialSearchResult.refinements
                    .firstWhere((element) => element.label == tab.text);
                final query =
                    widget.searchQuery.q + " " + currentRefinement.labelWithOp;
                print(query);
                return FutureBuilder(
                  future: widget.dataSource
                      .search(widget.searchQuery.copyWith(q: query)),
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
                        return ImageSearchResultPage(
                          widget.dataSource,
                          snapshot.data,
                          widget.searchQuery,
                          currentRefinement: currentRefinement,
                          withRefinementTabBar: false,
                        );
                    }
                  },
                );
              }
            }).toList(),
          ));
    }
  }
}
