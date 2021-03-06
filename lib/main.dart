import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as Http;

import 'apikey.dart';
import 'news_response.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'IN',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'IN'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const android = const MethodChannel('com.msasikanth.newsapp/android');
  static const ios = const MethodChannel('com.msasikanth.newsapp/ios');

  final String _apiKey = '${Api.key}';
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  List _newsItems = [];
  List<Country> _countries = countries;

  int _selectedCountry = 0;
  VoidCallback _countriesBottomSheet;

  Future<NewsSource> loadNews() async {
    _newsItems.clear();
    var _country = _countries[_selectedCountry].code;
    final response = await Http.get(
        'https://newsapi.org/v2/top-headlines?country=$_country&apiKey=$_apiKey');
    final responseJson = json.decode(response.body);
    return new NewsSource.fromJson(responseJson);
  }

  void _showBottomSheet() {
    setState(() {
      // BottomSheet opened
      _countriesBottomSheet = null;
    });

    _scaffoldState.currentState
        .showBottomSheet((BuildContext context) {
          return ListView.builder(
              itemCount: _countries.length,
              itemBuilder: (BuildContext context, int position) {
                ThemeData themeData = Theme.of(context);
                return Material(
                  child: InkWell(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(_countries[position].name.toUpperCase(),
                                style: TextStyle(
                                    letterSpacing: 1.0,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        position == _selectedCountry
                            ? Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Icon(Icons.check_circle,
                                    color: themeData.primaryColor),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Icon(Icons.check_circle_outline,
                                    color: Colors.black),
                              )
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        Navigator.pop(context);
                        _selectedCountry = position;
                        loadNews().then((source) {
                          setState(() {
                            _newsItems.addAll(source.articles);
                          });
                        });
                      });
                    },
                  ),
                );
              });
        })
        .closed
        .whenComplete(() {
          if (mounted) {
            setState(() {
              _countriesBottomSheet = _showBottomSheet;
            });
          }
        });
  }

  @override
  void initState() {
    super.initState();
    _countriesBottomSheet = _showBottomSheet;
    loadNews().then((source) {
      setState(() {
        _newsItems.addAll(source.articles);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldState,
      appBar: new AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: new Text(
            _countriesBottomSheet == null ? "Countries" : widget.title,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.map, color: Colors.white),
              onPressed: _countriesBottomSheet)
        ],
      ),
      body: buildList(),
      backgroundColor: Colors.white,
    );
  }

  Widget buildList() {
    if (_newsItems.isEmpty) {
      return Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: LinearProgressIndicator(),
              width: 160.0,
              height: 4.0,
            )
          ],
        ),
      );
    } else {
      return new ListView.builder(
          itemCount: _newsItems.length,
          itemBuilder: (BuildContext context, int position) => Material(
                color: Colors.white,
                child: InkWell(
                  child: newsLayout(position),
                  onTap: () {
                    if (Theme.of(context).platform == TargetPlatform.android) {
                      final url = (_newsItems[position] as NewsItem).url;
                      final parameter = {"url": url};
                      android.invokeMethod(
                          "launchUrl", new Map.from(parameter));
                    } else if (Theme.of(context).platform ==
                        TargetPlatform.iOS) {
                      final url = (_newsItems[position] as NewsItem).url;
                      final parameter = {"url": url};
                      ios.invokeMethod("launchUrl", new Map.from(parameter));
                    } else {
                      // Do nothing
                    }
                  },
                ),
              ));
    }
  }

  Widget newsLayout(int position) {
    final newsItem = _newsItems[position] as NewsItem;

    return Column(
      children: <Widget>[
        newsInnerLayout(newsItem),
        Divider(height: 1.0, color: new Color.fromARGB(0xCC, 224, 224, 224))
      ],
    );
  }

  Widget newsInnerLayout(NewsItem newsItem) {
    return new Row(
      children: <Widget>[
        Expanded(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 24.0, top: 16.0),
                child: Text(newsItem.source.name.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        letterSpacing: 0.5,
                        fontSize: 10.0,
                        color: Colors.grey.shade600)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 8.0, 16.0, 16.0),
                child: Text(newsItem.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: TextStyle(
                        height: 1.25,
                        fontFamily: 'CreteRound',
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                        color: Colors.black)),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
              left: 16.0, right: 24.0, top: 24.0, bottom: 24.0),
          child: handleImageView(newsItem.urlToImage),
        )
      ],
    );
  }

  Widget handleImageView(String url) {
    dynamic widget;
    if (url != null) {
      widget = Image.network(url, height: 96.0, width: 96.0, fit: BoxFit.cover);
    } else {
      widget = Container(height: 0.0, width: 0.0);
    }
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      child: Container(
        color: Colors.grey.shade300,
        child: widget,
      ),
    );
  }
}
