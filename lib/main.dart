// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Gif search'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController editingController = TextEditingController();
  String _searchQuery = "";
  List<dynamic> _gifs = [];

  void _fetchGifs() async {
    Uri apiUrl;
    if (_searchQuery == "") {
      apiUrl = Uri.parse(
          'https://api.giphy.com/v1/gifs/trending?api_key=DOthYIIXGUzcO2eqKtZkE9WIUxHZLO9n&lang=en');
    } else {
      apiUrl = Uri.parse(
          'https://api.giphy.com/v1/gifs/search?q=$_searchQuery&api_key=DOthYIIXGUzcO2eqKtZkE9WIUxHZLO9n&lang=en');
    }

    final response = await http.get(apiUrl);
    final data = json.decode(response.body);
    setState(() {
      _gifs = data['data'];
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchGifs();
  }

  Timer? timer;
  onSearchValuesChanged(String text) async {
    timer?.cancel();
    timer = Timer(
      const Duration(milliseconds: 250),
      () {
        setState(() {
          _searchQuery = text;
        });
        _fetchGifs();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              onChanged: (text) {
                onSearchValuesChanged(text);
              },
              controller: editingController,
              decoration: InputDecoration(
                  labelText: "Search",
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25)))),
            ),
            Expanded(
                child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8),
                    itemCount: _gifs.length,
                    itemBuilder: (context, index) {
                      final gif = _gifs[index];
                      final imageUrl = gif['images']['fixed_height']['url'];
                      return CachedNetworkImage(
                          imageUrl: imageUrl,
                          placeholder: (context, url) => SizedBox(
                                height: 50.0,
                                width: 50.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ));
                    }))
          ],
        ),
      ),
    );
  }
}
