# youtube_player

![pub version] 0.0.2


## Platform Support

| Windows | Android | iOS | Web |
| :-----: | :-----: | :-----: | :-----: |
|    ✔️    |    ✔️   |    ✔️   |    ✔️   |


## Example

```
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

```