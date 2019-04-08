import 'package:flutter/material.dart';
import 'package:flutter_app_cse/model/search_data_source.dart';
import 'package:url_launcher/url_launcher.dart';

class PromotionCard extends StatelessWidget {
  const PromotionCard({@required this.promotion});

  final Promotion promotion;

  Widget _generateTitleTile(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListTile(
      title: Text(
        '[promotion] ' + this.promotion.title,
        style: theme.textTheme.headline.copyWith(
            fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
      subtitle: new Text(
        this.promotion.displayLink,
        style:
            theme.textTheme.body1.copyWith(fontSize: 14.0, color: Colors.green),
      ),
    );
  }

  Widget _generateBodyTile(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.only(
        left: 8.0,
        bottom: 8.0,
      ),
      child: new Row(children: [
        // TODO: wait until CSE fix their API.
//        Expanded(
//            flex: 1,
//            child:
//                Image.network('https:' + this.promotion.promotionImage.source)),
        Expanded(
//            flex: 4,
            child: Container(
                padding: const EdgeInsets.only(left: 4.0, right: 8.0),
                child: Text(
                  '[promotion] ' + this.promotion.promotionBodyLines[0].title,
                  style: theme.textTheme.body1,
                  textAlign: TextAlign.left,
                ))),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
        onTap: () async {
          if (await canLaunch(this.promotion.link)) {
            await launch(this.promotion.link);
          }
        },
        child: Container(
          decoration: new BoxDecoration(boxShadow: [
            new BoxShadow(
              color: Colors.grey,
              blurRadius: 1.0,
            ),
          ]),
          child: new Card(
            color: Colors.lightGreen[50],
            child: Column(
              children: [
                _generateTitleTile(context),
                new Divider(color: Colors.black26),
                _generateBodyTile(context),
              ],
            ),
          ),
        ));
  }
}
