import 'package:flutter/material.dart';
import 'package:flutter_app_cse/search_data_source.dart';
import 'package:flutter_app_cse/custom_search_search_delegate.dart';
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
  imageSearch
}

class CustomSearchDemoPage extends StatefulWidget {
  final customSearchDemoType;

  CustomSearchDemoPage(this.customSearchDemoType);

  @override
  _CustomSearchDemoPageState createState() {
    switch (this.customSearchDemoType) {
      case CustomSearchDemoType.staticWebSearch:
        return _CustomSearchDemoPageState.fakeStaticSource();
      case CustomSearchDemoType.staticImageSearch:
        return _CustomSearchDemoPageState.fakeStaticSourceImageSearch();
      case CustomSearchDemoType.webSearch:
        return _CustomSearchDemoPageState.customWebSearch();
      case CustomSearchDemoType.imageSearch:
        return _CustomSearchDemoPageState.customImageSearch();
      default:
        return null;
    }
  }
}

class _CustomSearchDemoPageState extends State<CustomSearchDemoPage> {
  CustomSearchSearchDelegate delegate;
  String hintText;

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

  _CustomSearchDemoPageState.customImageSearch() {
    this.delegate = new CustomSearchInfiniteSearchDelegate.imageSearch(
        dataSource: CustomSearchDataSource(
            cx: '013098254965507895640:wyytcpldjbw',
            apiKey: ''));
    this.hintText = 'Google Custom Image Search';
    otherRoutes = [
      Tuple2<String, String>('Custom Web Search Demo', '/websearch')
    ];
  }

  _CustomSearchDemoPageState.customWebSearch() {
    this.delegate = new CustomSearchInfiniteSearchDelegate(
        dataSource: CustomSearchDataSource(
            cx: '013098254965507895640:0l32iqt_8jq',
            apiKey: ''));
    this.hintText = 'Google Custom Web Search';
    otherRoutes = [
      Tuple2<String, String>('Custom Image Search Demo', '/imagesearch')
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
                  accountName: const Text('Zach Widget'),
                  accountEmail: const Text('zach.widget@example.com'),
                  currentAccountPicture: const CircleAvatar(
                    backgroundImage: const AssetImage(
                      'shrine/vendors/zach.jpg',
                      package: 'flutter_gallery_assets',
                    ),
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