import 'dart:async';
import 'package:flutter_radio/flutter_radio.dart';
import 'package:flutter/material.dart';
import 'audio_provider.dart';
import 'package:http/http.dart' show get;
import 'dart:convert';

class AudioUrl {
  int id;
  String audiourl;
  AudioUrl({this.id, this.audiourl});

  factory AudioUrl.fromJson(Map<String, dynamic> json) {
    return AudioUrl(
        id: json['MessageAudioId'], audiourl: Uri.encodeFull(json['AudioUrl']));
  }
}

class AudioFeeds {
  final int id;
  final String title, imageUrl, propellant;
  final AudioUrl messageAudio;

  AudioFeeds(
      {this.id, this.title, this.imageUrl, this.propellant, this.messageAudio});

  factory AudioFeeds.fromJson(Map<String, dynamic> jsonData) {
    return AudioFeeds(
        id: jsonData['MessageId'],
        title: jsonData['Title'],
        propellant: jsonData['DateRealeased'],
        imageUrl: jsonData['MessageCoverPicture'],
        messageAudio: AudioUrl.fromJson(jsonData['MessageAudio']));
  }
}

class CustomListView extends StatelessWidget {
  final List<AudioFeeds> audioFeeds;
  static const hostURL = "http://nccjos.org/";

  CustomListView(this.audioFeeds);

  Widget build(context) {
    return ListView.builder(
      itemCount: audioFeeds.length,
      itemBuilder: (context, int currentIndex) {
        return createViewItem(audioFeeds[currentIndex], context);
      },
    );
  }

  Widget createViewItem(AudioFeeds audioFeed, BuildContext context) {
    return new ListTile(
        title: new Card(
          elevation: 5.0,
          child: new Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.orange)),
            padding: EdgeInsets.all(20.0),
            margin: EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Padding(
                  child: Image.network('$hostURL${audioFeed.imageUrl}'),
                  padding: EdgeInsets.only(bottom: 8.0),
                ),
                Row(children: <Widget>[
                  Padding(
                      child: Text(
                        audioFeed.title,
                        style: new TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                      padding: EdgeInsets.all(1.0)),
                  Text(" | "),
                  Padding(
                      child: Text(
                        audioFeed.propellant,
                        style: new TextStyle(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.right,
                      ),
                      padding: EdgeInsets.all(1.0)),
                ]),
              ],
            ),
          ),
        ),
        onTap: () {
          //We start by creating a Page Route.
          //A MaterialPageRoute is a modal route that replaces the entire
          //screen with a platform-adaptive transition.
          var route = new MaterialPageRoute(
            builder: (BuildContext context) =>
                new SecondScreen(value: audioFeed),
          );
          //A Navigator is a widget that manages a set of child widgets with
          //stack discipline.It allows us navigate pages.
          Navigator.of(context).push(route);
        });
  }
}

//Future is n object representing a delayed computation.
Future<List<AudioFeeds>> downloadJSON() async {
  // final jsonEndpoint =
  //     "https://raw.githubusercontent.com/Oclemy/SampleJSON/338d9585/spacecrafts.json";
  final jsonEndpoint = "http://nccjos.org/api/Sermons/GetAllSermons";

  final response = await get(jsonEndpoint);

  if (response.statusCode == 200) {
    List audioFeeds = json.decode(response.body);
    return audioFeeds
        .map((parsedAudioFeeds) => new AudioFeeds.fromJson(parsedAudioFeeds))
        .toList();
  } else
    throw Exception('We were not able to successfully download the json data.');
}

class SecondScreen extends StatefulWidget {
  final AudioFeeds value;

  SecondScreen({Key key, this.value}) : super(key: key);

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  static const streamUrl =
      "https://ia802708.us.archive.org/3/items/count_monte_cristo_0711_librivox/count_of_monte_cristo_001_dumas.mp3";

  bool isPlaying;
  static const hostURL = "http://nccjos.org/";

  @override
  void initState() {
    super.initState();
    audioStart();
    playingStatus();
  }

  Future<void> audioStart() async {
    await FlutterRadio.audioStart();
    print('Audio Start OK');
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Detail Page')),
      body: new Container(
        child: new Center(
          child: Column(
            children: <Widget>[
              Padding(
                child: new Text(
                  'MESSAGE DETAILS',
                  style: new TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20.0),
                  textAlign: TextAlign.center,
                ),
                padding: EdgeInsets.only(bottom: 20.0),
              ),
              Padding(
                //`widget` is the current configuration. A State object's configuration
                //is the corresponding StatefulWidget instance.
                child: Image.network('$hostURL${widget.value.imageUrl}'),
                padding: EdgeInsets.only(bottom: 8.0),
              ),
              Padding(
                child: new Text(
                  'NAME : ${widget.value.title}',
                  style: new TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                padding: EdgeInsets.all(20.0),
              ),
              Padding(
                child: new Text(
                  'PROPELLANT : ${widget.value.propellant}',
                  style: new TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                padding: EdgeInsets.all(20.0),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RaisedButton(
                    child: Icon(Icons.play_circle_filled),
                    color: Colors.green,
                    onPressed: () {
                      FlutterRadio.playOrPause(
                          url: '$hostURL${widget.value.messageAudio.audiourl}');
                      playingStatus();
                    },
                  ),
                  RaisedButton(
                    child: Icon(Icons.pause_circle_filled),
                    color: Colors.red,
                    onPressed: () {
                      FlutterRadio.playOrPause(
                          url: '$hostURL${widget.value.messageAudio.audiourl}');
                      playingStatus();
                    },
                  ),
                  RaisedButton(
                    child: Icon(Icons.stop),
                    color: Colors.blue,
                    onPressed: () {
                      FlutterRadio.playOrPause(
                          url: '$hostURL${widget.value.messageAudio.audiourl}');
                      playingStatus();
                    },
                  )
                ],
              ),
              Text(
                'Check Playback Status: $isPlaying',
                style: TextStyle(fontSize: 25.0),
              ),
              RaisedButton(
                child: const Text('Play Local', style: TextStyle(fontSize: 20)),
                color: Colors.lightBlueAccent,
                onPressed: () {
                  //A MaterialPageRoute is a modal route that replaces the entire
                  //screen with a platform-adaptive transition.
                  var route = new MaterialPageRoute(
                    builder: (BuildContext context) => new AudioApp(),
                  );
                  // new AudioApp(value: audioFeed),
                  //A Navigator is a widget that manages a set of child widgets with
                  //stack discipline.It allows us navigate pages.
                  Navigator.of(context).push(route);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future playingStatus() async {
    bool isP = await FlutterRadio.isPlaying();
    setState(() {
      isPlaying = isP;
    });
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: new Scaffold(
        appBar: new AppBar(title: const Text('CHURCH ONLINE MESSAGES')),
        body: new Center(
          //FutureBuilder is a widget that builds itself based on the latest snapshot
          // of interaction with a Future.
          child: new FutureBuilder<List<AudioFeeds>>(
            future: downloadJSON(),
            //we pass a BuildContext and an AsyncSnapshot object which is an
            //Immutable representation of the most recent interaction with
            //an asynchronous computation.
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<AudioFeeds> audioFeeds = snapshot.data;
                return new CustomListView(audioFeeds);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              //return  a circular progress indicator.
              return new CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
