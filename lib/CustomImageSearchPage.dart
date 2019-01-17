import 'package:flutter/material.dart';
import 'package:flutter_app_cse/search_data_source.dart';
import 'package:flutter_app_cse/search_result_page.dart';

class CustomImageSearchDemo extends StatefulWidget {
  @override
  _CustomImageSearchDemoState createState() =>
      new _CustomImageSearchDemoState();
}

class _CustomImageSearchDemoState extends State<CustomImageSearchDemo> {
  final CustomSearchSearchDelegate _delegate =
      CustomSearchSearchDelegate.fakeStaticImageSearchSource();

//  final CustomSearchSearchDelegate _delegate =
//      new CustomSearchSearchDelegate.imageSearch(
//          dataSource: CustomSearchDataSource(
//              cx: '',
//              apiKey: ''),
//          autoCompleteDataSource: CommonEnglishWordAutoCompleteDataSource());
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void triggerShowSearch() async {
    await showSearch<SearchResult>(
      context: context,
      delegate: _delegate,
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
            color: Colors.white,
            progress: _delegate.transitionAnimation,
          ),
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
        ),
        title: new TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Google Custom Image Search',
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
            ),
            new MediaQuery.removePadding(
              context: context,
              // DrawerHeader consumes top MediaQuery padding.
              removeTop: true,
              child: ListTile(
                leading: const Icon(Icons.payment),
                title: const Text('Custom Web Search Demo'),
                onTap: () {
                  Navigator.pushNamed(context, '/websearch');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
