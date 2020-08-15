import 'package:flutter/material.dart';
import 'package:gradient_text/gradient_text.dart';
import 'package:english_words/english_words.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Startup Name Generator!',
      theme: ThemeData(
        primaryColor: Colors.tealAccent,
        accentColor: Colors.cyanAccent,
        scaffoldBackgroundColor: Colors.cyanAccent,
        //textTheme: TextTheme(bodyText2: TextStyle(color: Colors.white)),
      ),
      home:RandomWords(),
    );
  }
}
class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => RandomWordsState();
}
class RandomWordsState extends State<RandomWords>{
  @override
  final _suggestions = <WordPair>[];
  var _saved = Set<WordPair>();
  final nicestyle = const TextStyle(
    fontSize: 22,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.bold,
  );
  final nicegradient = const LinearGradient(
      colors: [
        Colors.deepPurple,
        Colors.deepOrange,
        Colors.pink,
      ]
  );
  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context,i) {
          if (i.isOdd) return Divider();
          final index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
        }
    );
  }
  Widget _buildRow(WordPair pair) {
    final bool alreadySaved = _saved.contains(pair);
    return ListTile(
      title: GradientText(
        pair.asPascalCase,
        gradient: nicegradient,
        style: nicestyle,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red: null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          }
          else {
            _saved.add(pair);
          }
        });
      },
    );
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator!'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.bookmark), onPressed: _pushSaved),
        ],
      ),
      body: _buildSuggestions(),
    );
  }
  void _pushSaved() async{
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return SecondScreen(_saved,nicestyle,nicegradient);
        },
      ),
    );
    setState((){
      _saved = result;
    });
  }
}
class SecondScreen extends StatefulWidget {
  final Set<WordPair> _saved;
  final TextStyle nicestyle;
  final LinearGradient nicegradient;
  const SecondScreen(this._saved, this.nicestyle, this.nicegradient);
  @override
  _SecondScreenState createState() => _SecondScreenState();
}
class _SecondScreenState extends State<SecondScreen> {
  _createTiles() {
    var tiles = widget._saved.map((WordPair pair) {
      return WillPopScope(
        onWillPop: () {
          Navigator.pop(context, widget._saved);
          return Future(() => false);
        },
        child: ListTile(
          title: GradientText(
            pair.asPascalCase,
            gradient: widget.nicegradient,
            style: widget.nicestyle,
          ),
          trailing: Icon(Icons.delete),
          onTap: (){
            _removePair(pair);
          },
        ),
      );
    });
    var divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();
    return divided;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Saved Suggestions"),
      ),
      body: ListView(children: _createTiles()),
    );
  }
  void _removePair(WordPair pair) {
    if (widget._saved.contains(pair))
      setState((){
        widget._saved.remove(pair);
      });
  }
}