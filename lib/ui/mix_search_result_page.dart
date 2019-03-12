import 'package:flutter/material.dart';

import '../search_data_source.dart';
import 'web_search_result_page.dart';
import 'image_search_result_page.dart';
import 'loading_progress_indicator.dart';

class MixSearchResultPage extends StatefulWidget {
  final SearchDataSource dataSource;
  final SearchResults initialSearchResult;
  final SearchQuery searchQuery;

  MixSearchResultPage(
      this.dataSource, this.initialSearchResult, this.searchQuery);

  @override
  State createState() => new _MixSearchResultPageState(initialSearchResult);
}

class _MixSearchResultPageState extends State<MixSearchResultPage>
    with SingleTickerProviderStateMixin {
  final SearchResults initialSearchResult;
  List<Tab> _searchTypeTabs = new List<Tab>();
  TabController _tabController;

  _MixSearchResultPageState(this.initialSearchResult) {
    _searchTypeTabs.add(Tab(text: 'Web'));
    _searchTypeTabs.add(Tab(text: 'Image'));
    _tabController = TabController(vsync: this, length: _searchTypeTabs.length);
  }

  @override
  void dispose() {
    this._searchTypeTabs.clear();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    tabs: _searchTypeTabs,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: _searchTypeTabs.map((Tab tab) {
            if (tab.text == 'Web') {
              return WebSearchResultPage(widget.dataSource,
                  widget.initialSearchResult, widget.searchQuery);
            } else {
              final imageQuery =
                  widget.searchQuery.copyWith(searchType: 'image');
              return FutureBuilder<SearchResults>(
                future: widget.dataSource.search(imageQuery),
                builder: (BuildContext context,
                    AsyncSnapshot<SearchResults> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return Text('Press button to start.');
                    case ConnectionState.active:
                    case ConnectionState.waiting:
                      return loadingProgressIndicator(context);
                    case ConnectionState.done:
                      if (snapshot.hasError)
                        return Text('Error: ${snapshot.error}');
                      return ImageSearchResultPage(
                          widget.dataSource, snapshot.data, imageQuery);
                  }
                  return null; // unreachable
                },
              );
            }
          }).toList(),
        ));
  }
}
