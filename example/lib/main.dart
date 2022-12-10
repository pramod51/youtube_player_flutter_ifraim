import 'package:flutter/material.dart';
import 'package:youtube_player_flutter_ifraim/youtube_player.dart';

void main() {
  runApp(const MyApp());
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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 280,
      child: YoutubePlayer(
        controller: YoutubePlayerController(
            youtubeUrl: 'https://www.youtube.com/watch?v=BddP6PYo2gs'),
      ),
    );
  }
}
