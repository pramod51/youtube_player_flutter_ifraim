# youtube_player

![pub version] 0.0.2


## Platform Support

| Windows | Android | iOS | Web |
| :-----: | :-----: | :-----: | :-----: |
|    ✅    |    ✅   |   ✅   |    ✅   |


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

### getPlayerStateCode #

| playerStateCode | Message    |
|-----------------|------------|
|        -1       | unstarted  |
|        0        | ended      |
|        1        | playing    |
|        2        | paused     |
|        3        | buffering  |
|        5        | video cued |



### getPlayerError #
| errorCode | message                                                                                                                                                                                                                              |
|-----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|     2     | The request contains an invalid parameter value. For example, this error occurs if you specify a video ID that does not have 11 characters, or if the video ID contains invalid characters, such as exclamation points or asterisks. |
|     5     | The requested content cannot be played in an HTML5 player or another error related to the HTML5 player has occurred.                                                                                                                 |
|    100    | The video requested was not found. This error occurs when a video has been removed (for any reason) or has been marked as private.                                                                                                   |
|    101    | The owner of the requested video does not allow it to be played in embedded players.                                                                                                                                                 |
|    150    | This error is the same as 101. It's just a 101 error in disguise!                                                                                                                                                                    |



