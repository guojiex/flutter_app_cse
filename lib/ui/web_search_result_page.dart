import 'package:flutter/material.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';

import 'package:flutter_app_cse/model/search_data_source.dart';
import 'no_result_card.dart';
import 'web_search_result_card.dart';
import 'loading_progress_indicator.dart';
import 'promotion_card.dart';

@immutable
class WebSearchResultPage extends StatefulWidget {
  final SearchDataSource dataSource;
  final SearchResults initialSearchResult;
  final SearchQuery searchQuery;
  final Refinement currentRefinement;
  final bool withRefinementTabBar;

  WebSearchResultPage(this.dataSource, this.initialSearchResult,
      this.searchQuery,
      {this.currentRefinement, this.withRefinementTabBar = true});

  @override
  _WebSearchResultPageState createState() =>
      new _WebSearchResultPageState(initialSearchResult);
}

class _WebSearchResultPageState extends State<WebSearchResultPage>
    with SingleTickerProviderStateMixin {
  SearchResults initialSearchResult;
  SearchResults currentSearchResults;
  TabController _tabController;
  List<Tab> _refinementTabs = new List<Tab>();

  _WebSearchResultPageState(this.initialSearchResult) {
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
    this._refinementTabs.clear();
    _tabController?.dispose();
    super.dispose();
  }

  Widget _buildWebSearchResultSubList(SearchResults searchResults) {
    return ListView(
        shrinkWrap: true,
        primary: false,
        children: _buildWebResultWidgetList(searchResults));
  }

  List<Widget> _buildWebResultWidgetList(SearchResults searchResults) {
    List<Widget> _results = new List<Widget>();
    _results.addAll(searchResults.promotions
        .map((promotion) => PromotionCard(promotion: promotion)));
    _results.addAll(searchResults.searchResults.map(
            (searchResult) => WebSearchResultCard(searchResult: searchResult)));
    return _results;
  }

  Widget _buildWebListPage(BuildContext context) {
    return ListView.builder(
        itemCount:
            10, // Custom Search API will not return more than 100 results.
        itemBuilder: (BuildContext context, int index) {
          print('$index');
          if (index == 0) {
            this.currentSearchResults = initialSearchResult;
            if (currentSearchResults.searchResults.isEmpty) {
              return noResultCardInContainer(context);
            }
            return _buildWebSearchResultSubList(initialSearchResult);
          }
          if (currentSearchResults.nextPage != null) {
            return FutureBuilder(
              future: widget.dataSource.search(currentSearchResults.nextPage),
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
                    this.currentSearchResults = snapshot.data;
                    if (currentSearchResults.searchResults.isEmpty) {
                      return noResultCardInContainer(context);
                    }
                    return _buildWebSearchResultSubList(snapshot.data);
                }
              },
            );
          } else {
            return Container(width: 0.0, height: 0.0);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    if (this._refinementTabs.isEmpty || !widget.withRefinementTabBar) {
      return _buildWebListPage(context);
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
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: new BubbleTabIndicator(
                        indicatorHeight: 30.0,
                        indicatorColor: Colors.white,
                        tabBarIndicatorSize: TabBarIndicatorSize.tab,
                      ),
                      isScrollable: true,
                      controller: _tabController,
                      tabs: _refinementTabs,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.white70,
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
                return _buildWebListPage(context);
              } else {
                final currentRefinement = initialSearchResult.refinements
                    .firstWhere((element) => element.label == tab.text);
                final query =
                    widget.searchQuery.q + " " + currentRefinement.labelWithOp;
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
                        return WebSearchResultPage(
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
