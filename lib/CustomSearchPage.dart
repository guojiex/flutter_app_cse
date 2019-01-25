import 'package:flutter/material.dart';
import 'package:flutter_app_cse/search_data_source.dart';
import 'package:flutter_app_cse/search_result_page.dart';
import 'package:tuple/tuple.dart';

enum CustomSearchDemoType {
  staticWebSearch,
  staticImageSearch,
  webSearch,
  imageSearch
}

class CustomSearchDemo extends StatefulWidget {
  final customSearchDemoType;

  CustomSearchDemo(this.customSearchDemoType);

  @override
  _CustomSearchDemoState createState() {
    switch (this.customSearchDemoType) {
      case CustomSearchDemoType.staticWebSearch:
        return _CustomSearchDemoState.fakeStaticSource();
      case CustomSearchDemoType.staticImageSearch:
        return _CustomSearchDemoState.fakeStaticSourceImageSearch();
      case CustomSearchDemoType.webSearch:
        return _CustomSearchDemoState.customWebSearch();
      case CustomSearchDemoType.imageSearch:
        return _CustomSearchDemoState.customImageSearch();
      default:
        return null;
    }
  }
}

class _CustomSearchDemoState extends State<CustomSearchDemo> {
  CustomSearchSearchDelegate delegate;
  String hintText;

  /// used to generate display name and route to other pages, in the left drawer.
  List<Tuple2<String, String>> otherRoutes;

  _CustomSearchDemoState(this.delegate, this.hintText);

  _CustomSearchDemoState.fakeStaticSource() {
    this.delegate = CustomSearchSearchDelegate.fakeStaticSource();
    this.hintText = 'Static Google Custom Web Search';
    otherRoutes = [
      Tuple2<String, String>('Custom Image Search Demo', '/imagesearch')
    ];
  }

  _CustomSearchDemoState.fakeStaticSourceImageSearch() {
    this.delegate = CustomSearchSearchDelegate.fakeStaticSourceImageSearch();
    this.hintText = 'Static Google Custom Image Search';
    otherRoutes = [
      Tuple2<String, String>('Custom Web Search Demo', '/websearch')
    ];
  }

  _CustomSearchDemoState.customImageSearch() {
    this.delegate = new CustomSearchSearchDelegate.imageSearch(
        dataSource: CustomSearchDataSource(cx: '', apiKey: ''));
    this.hintText = 'Google Custom Image Search';
    otherRoutes = [
      Tuple2<String, String>('Custom Web Search Demo', '/websearch')
    ];
  }

  _CustomSearchDemoState.customWebSearch() {
    this.delegate = new CustomSearchSearchDelegate(
        dataSource: CustomSearchDataSource(cx: '', apiKey: ''));
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
