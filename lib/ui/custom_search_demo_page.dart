import 'package:flutter/material.dart';
import 'package:flutter_app_cse/model/search_data_source.dart';
import 'package:flutter_app_cse/model/custom_search_search_delegate.dart';
import 'package:tuple/tuple.dart';

/// Different types of Search Demo Page.
enum CustomSearchDemoType {
  /// Type 'web' to get static search result.
  staticWebSearch,

  /// Type 'image' to get static image search result.
  staticImageSearch,

  /// Search for web.
  webSearch,

  /// Search for image.
  imageSearch,

  promotionWebSearch,

  // Search for image or web.
  mixSearch,
}

class CustomSearchDemoPage extends StatefulWidget {
  final customSearchDemoType;
  final String apiKey;

  CustomSearchDemoPage(this.customSearchDemoType, this.apiKey);

  @override
  _CustomSearchDemoPageState createState() {
    switch (this.customSearchDemoType) {
      case CustomSearchDemoType.staticWebSearch:
        return _CustomSearchDemoPageState.fakeStaticSource();
      case CustomSearchDemoType.staticImageSearch:
        return _CustomSearchDemoPageState.fakeStaticSourceImageSearch();
      case CustomSearchDemoType.webSearch:
        return _CustomSearchDemoPageState.customWebSearch(apiKey);
      case CustomSearchDemoType.imageSearch:
        return _CustomSearchDemoPageState.customImageSearch(apiKey);
      case CustomSearchDemoType.promotionWebSearch:
        return _CustomSearchDemoPageState.customPromotionWebSearch(apiKey);
      case CustomSearchDemoType.mixSearch:
        return _CustomSearchDemoPageState.customMixSearch(apiKey);
      default:
        return null;
    }
  }
}

class _CustomSearchDemoPageState extends State<CustomSearchDemoPage> {
  CustomSearchSearchDelegate delegate;
  String hintText;
  String apiKey;

  /// used to generate display name and route to other pages, in the left drawer.
  List<Tuple2<String, String>> otherRoutes;

  _CustomSearchDemoPageState(this.delegate, this.hintText);

  _CustomSearchDemoPageState.fakeStaticSource() {
    this.delegate = CustomSearchSearchDelegate.fakeStaticSource();
    this.hintText = 'Static Google Custom Web Search';
    otherRoutes = [
      Tuple2<String, String>('Custom Image Search Demo', '/imagesearch')
    ];
  }

  _CustomSearchDemoPageState.fakeStaticSourceImageSearch() {
    this.delegate = CustomSearchSearchDelegate.fakeStaticSourceImageSearch();
    this.hintText = 'Static Google Custom Image Search';
    otherRoutes = [
      Tuple2<String, String>('Custom Web Search Demo', '/websearch')
    ];
  }

  _CustomSearchDemoPageState.customImageSearch(String apiKey) {
    // Pokemon db with refinement.
    this.delegate = new CustomSearchInfiniteSearchDelegate.imageSearch(
        dataSource: CustomSearchDataSource(
            cx: '013098254965507895640:g-r0nurxf2g', apiKey: apiKey));
    this.hintText = 'Google Custom Image Search';
    otherRoutes = [
      Tuple2<String, String>('Custom Web Search Demo', '/websearch'),
      Tuple2<String, String>(
          'Custom Web Search Promotion Demo', '/promotionwebsearch'),
      Tuple2<String, String>('Custom Mix Search Demo', '/mixsearch')
    ];
  }

  _CustomSearchDemoPageState.customWebSearch(String apiKey) {
    // New York Times with refinement.
    this.delegate = new CustomSearchInfiniteSearchDelegate(
        dataSource: CustomSearchDataSource(
            cx: '013098254965507895640:zjg6lv-gsvg', apiKey: apiKey));
    this.hintText = 'Google Custom Web Search';
    otherRoutes = [
      Tuple2<String, String>('Custom Image Search Demo', '/imagesearch'),
      Tuple2<String, String>(
          'Custom Web Search Promotion Demo', '/promotionwebsearch'),
      Tuple2<String, String>('Custom Mix Search Demo', '/mixsearch')
    ];
  }

  _CustomSearchDemoPageState.customPromotionWebSearch(String apiKey) {
    // flutter with promotion
    // Trigger promotion by searching for flutter.*
    this.delegate = new CustomSearchInfiniteSearchDelegate(
        dataSource: CustomSearchDataSource(
            cx: '013098254965507895640:ebp1trsjo0a', apiKey: apiKey));
    this.hintText = 'Custom Web Search with Promotion';
    otherRoutes = [
      Tuple2<String, String>('Custom Web Search Demo', '/websearch'),
      Tuple2<String, String>('Custom Image Search Demo', '/imagesearch'),
      Tuple2<String, String>('Custom Mix Search Demo', '/mixsearch')
    ];
  }

  _CustomSearchDemoPageState.customMixSearch(String apiKey) {
    // Pokemon db with refinement.
    this.delegate = new CustomSearchInfiniteSearchDelegate.mixSearch(
        dataSource: CustomSearchDataSource(
            cx: '013098254965507895640:g-r0nurxf2g', apiKey: apiKey));
    this.hintText = 'Google Custom Mix Search';
    otherRoutes = [
      Tuple2<String, String>('Custom Web Search Demo', '/websearch'),
      Tuple2<String, String>('Custom Image Search Demo', '/imagesearch'),
      Tuple2<String, String>(
          'Custom Web Search Promotion Demo', '/promotionwebsearch')
    ];
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void triggerShowSearch() async {
    await showSearch<SearchResult>(
      context: context,
      delegate: delegate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        leading: new IconButton(
          tooltip: 'Navigation menu',
          icon: new AnimatedIcon(
            icon: AnimatedIcons.menu_arrow,
            progress: delegate.transitionAnimation,
          ),
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
        ),
        title: new TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: new TextStyle(color: theme.primaryTextTheme.title.color),
          ),
          onTap: triggerShowSearch,
          textInputAction: TextInputAction.search,
        ),
        actions: <Widget>[
          new IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: triggerShowSearch,
          ),
        ],
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new MergeSemantics(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      const Text('Press the '),
                      const Tooltip(
                        message: 'search',
                        child: const Icon(
                          Icons.search,
                          size: 18.0,
                        ),
                      ),
                      const Text(' icon in the AppBar'),
                    ],
                  ),
                  const Text('and search for a word.'),
                ],
              ),
            ),
            const SizedBox(height: 64.0),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton.extended(
        tooltip: 'Back', // Tests depend on this label to exit the demo.
        onPressed: () {
          Navigator.of(context).pop();
        },
        label: const Text('Close demo'),
        icon: const Icon(Icons.close),
      ),
      drawer: new Drawer(
        child: new Column(
          children: <Widget>[
                const UserAccountsDrawerHeader(
                  accountName: const Text('JG'),
                  accountEmail: const Text('jiexing.jg@gmail.com'),
                  currentAccountPicture: const CircleAvatar(
                    backgroundImage: const NetworkImage(
                        'https://avatars2.githubusercontent.com/u/5022480?s=400&u=4e1d662c77ac14e14f7a0387aca08728a22ee587&v=4'),
                  ),
                  margin: EdgeInsets.zero,
                )
              ] +
              List.generate(otherRoutes.length, (index) {
                return new MediaQuery.removePadding(
                  context: context,
                  // DrawerHeader consumes top MediaQuery padding.
                  removeTop: true,
                  child: ListTile(
                    leading: const Icon(Icons.payment),
                    title: Text(otherRoutes[index].item1),
                    onTap: () {
                      Navigator.pushNamed(context, otherRoutes[index].item2);
                    },
                  ),
                );
              }),
        ),
      ),
    );
  }
}
