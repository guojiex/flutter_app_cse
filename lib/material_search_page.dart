import 'package:flutter/material.dart';
import 'package:flutter_app_cse/search_result_page.dart';

void main() => runApp(SearchDemoApp());

class SearchDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Custom Search Engine Flutter Demo', home: SearchDemo());
  }
}

class SearchDemo extends StatefulWidget {
  @override
  _SearchDemoState createState() => new _SearchDemoState();
}

class _SearchDemoState extends State<SearchDemo> {
  final FakeJsonSearchDelegate _delegate = new FakeJsonSearchDelegate();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String _inputQuery;

  void triggerShowSearch() async {
    final String input = await showSearch<String>(
      context: context,
      delegate: _delegate,
    );
    if (input != null && input != _inputQuery) {
      setState(() {
        _inputQuery = input;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            hintText: 'Custom search engine',
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
                  const Text(
                      'and search for a word.'),
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
              child: const ListTile(
                leading: const Icon(Icons.payment),
                title: const Text('Placeholder'),
              ),
            ),
          ],
        ),
      ),
    );
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
