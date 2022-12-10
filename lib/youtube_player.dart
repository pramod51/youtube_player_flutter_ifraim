import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter_ifraim/video_util.dart';
import 'package:webviewx/webviewx.dart';

class YoutubePlayerController {
  late YoutubePlayerState _youtubePlayerState;
  final String youtubeUrl;
  final bool mute;
  final Duration? startAt;
  final YoutubePlayerVars? playerVars;

  YoutubePlayerController({
    required this.youtubeUrl,
    this.mute = false,
    this.startAt,
    this.playerVars,
  });

  void playVideo() {
    _youtubePlayerState.playVideo();
  }

  void pauseVideo() {
    _youtubePlayerState.pauseVideo();
  }

  void muteVideo() async {
    await _youtubePlayerState.mute();
  }

  void unMuteVideo() async {
    await _youtubePlayerState.unMute();
  }

  void setVolume(int value) {
    _youtubePlayerState.setVolume(value);
  }

  void seekTo(Duration duration) {
    _youtubePlayerState.seekTo(duration.inMilliseconds / 1000);
  }

  Future<int> getVolume() {
    return _youtubePlayerState.getVolume();
  }

  bool isPlaying() {
    return _youtubePlayerState.isPlayingVideo;
  }

  bool isMute() {
    return _youtubePlayerState.isMute;
  }

  Future<int> getPlayerState() async {
    return _youtubePlayerState.getPlayerState();
  }

  void loadVideoById(String videoId) {
    _youtubePlayerState.loadVideoById(videoId);
  }

  void loadVideoByIdWithStartTime(String videoId, Duration startAt) {
    _youtubePlayerState.loadVideoByIdWithStartTime(
        videoId, startAt.inMilliseconds / 1000);
  }

  Future<Duration> getDuration() async {
    return _youtubePlayerState.getDuration();
  }
}

class YoutubePlayer extends StatefulWidget {
  final VoidCallback? onVideoEnded;
  final YoutubePlayerController controller;

  const YoutubePlayer({
    Key? key,
    required this.controller,
    this.onVideoEnded,
  }) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<YoutubePlayer> createState() {
    final playerState = YoutubePlayerState();

    controller._youtubePlayerState = playerState;
    return playerState;
  }
}

class YoutubePlayerState extends State<YoutubePlayer> {
  WebViewXController? webController;
  bool isPlayingVideo = false;
  bool isMute = false;
  Duration videoDuration = const Duration(); //total video length
  Duration videoTime = const Duration(); //running video duration
  bool isErrorOccurred = false;
  String videoId = '';
  late YoutubePlayerVars playerVars;

  @override
  void initState() {
    super.initState();
    isMute = widget.controller.mute;
    playerVars = widget.controller.playerVars ?? YoutubePlayerVars();
    videoId = VideoUtil.convertUrlToId(widget.controller.youtubeUrl) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    // return buildBlackScreen;
    // if (isErrorOccurred) {
    //   return Material(child: buildBlackScreen);
    // }
    return Material(
      child: Stack(
        children: [
          InkWell(
            onTap: _togglePlayPause,
            child: buildWebView,
          ),
          // if ((videoTime.inMilliseconds == 0 ||
          //         widget.controller.startAt != null) &&
          //     !isPlayingVideo) ...[
          //   buildThumbnail,
          // ],
          // if (videoDuration.inMilliseconds != 0) ...[
          //   Positioned.fill(
          //     child: SizedBox(child: Center(child: _buildPlayPauseButton)),
          //   ),
          // ] else ...[
          //   buildBlackScreen
          // ],
        ],
      ),
    );
  }

  Widget get buildWebView {
    return WebViewAware(
      child: WebViewX(
        width: double.maxFinite,
        height: double.maxFinite,
        dartCallBacks: {
          DartCallback(
            name: 'OnPlayerReady',
            callBack: onPlayerReady,
          ),
          DartCallback(
            name: 'OnPlayerError',
            callBack: onPlayerError,
          )
        },
        jsContent: const {
          EmbeddedJsContent(
            js: "function onPlayerReady(event) { OnPlayerReady(event) }",
          ),
          EmbeddedJsContent(
            js: "function onPlayerError(event) { OnPlayerError(event.data) }",
          ),
        },
        // ignoreAllGestures: true,
        initialSourceType: SourceType.html,
        onWebViewCreated: (controller) {
          webController = controller;
          loadYoutubeIfraim();
          setState(() {});
        },
      ),
    );
  }

  Widget get buildThumbnail {
    return Image.network(
      getThumbnailUrl,
      fit: BoxFit.cover,
      width: double.maxFinite,
      height: double.maxFinite,
      errorBuilder: (_, __, ___) => buildBlackScreen,
    );
  }

  /// Grabs YouTube video's thumbnail for provided video id.
  String get getThumbnailUrl =>
      'https://i3.ytimg.com/vi_webp/$videoId/maxresdefault.webp';
  // : 'https://i3.ytimg.com/vi/$videoId/$quality.jpg';

  void _togglePlayPause() {
    setState(() {
      if (isPlayingVideo) {
        pauseVideo();
      } else {
        playVideo();
      }
      isPlayingVideo = !isPlayingVideo;
    });
  }

  Widget get _buildPlayPauseButton {
    if (isPlayingVideo) return const SizedBox.shrink();
    return MaterialButton(
      onPressed: _togglePlayPause,
      color: Colors.black.withOpacity(0.6),
      textColor: Colors.white,
      padding: const EdgeInsets.all(24),
      shape: const CircleBorder(),
      child: Icon(
        isPlayingVideo ? Icons.pause : Icons.play_arrow,
        size: 30,
      ),
    );
  }

  void loadYoutubeIfraim() async {
    final playerHtml = await rootBundle.loadString(
        'packages/youtube_player_flutter_ifraim/assets/youtube_player.html');
    await webController?.loadContent(
      playerHtml
          .replaceFirst('<<videoId>>', videoId)
          .replaceAll('<<playerVars>>', playerVars.toMap().toString()),
      SourceType.html,
    );
  }

  void onTimeChange(double time) async {
    videoTime = Duration(milliseconds: (time * 1000).toInt());
    if (await getPlayerState() == 0) {
      videoTime = videoDuration;
      isPlayingVideo = false;
      widget.onVideoEnded?.call();
    }
    setState(() {});
  }

  Widget get buildBlackScreen => Container(
        color: Colors.black,
      );

  void onPlayerReady(event) async {
    debugPrint('Player is ready');
    webController?.callJsMethod('addVideoTimeListener', [onTimeChange]);
    videoDuration = await getDuration();
    if (widget.controller.startAt != null) {
      seekTo(widget.controller.startAt!.inSeconds.toDouble());
    }
    if (isMute) {
      mute();
    }
    if (playerVars.autoPlay) {
      isPlayingVideo = false;
      _togglePlayPause();
    }
    setState(() {});
  }

  void onPlayerError(errorCode) async {
    setState(() {
      isErrorOccurred = true;
    });
  }

  void pauseVideo() {
    webController?.callJsMethod('pauseVideo', []);
  }

  void playVideo() {
    webController?.callJsMethod('playVideo', []);
  }

  Future<void> mute() async {
    await webController?.callJsMethod('mute', []);
  }

  Future<void> unMute() async {
    await webController?.callJsMethod('unMute', []);
  }

  void setVolume(value) {
    webController?.callJsMethod('setVolume', [value]);
  }

  void seekTo(double seconds) {
    webController?.callJsMethod('seekTo', [seconds]);
  }

  Future<int> getVolume() async {
    return await webController?.callJsMethod('getVolume', []);
  }

  Future<bool> isPlaying() async {
    return await getPlayerState() == 1;
  }

  Future<int> getPlayerState() async {
    return await webController?.callJsMethod('getPlayerState', []);
  }

  void loadVideoById(videoId) {
    webController?.callJsMethod('loadVideoById', [videoId]);
  }

  void loadVideoByIdWithStartTime(videoId, startAt) {
    webController?.callJsMethod('loadVideoById', [videoId, startAt]);
  }

  Future<Duration> getDuration() async {
    final double duration =
        await webController?.callJsMethod('getDuration', []);
    return Duration(milliseconds: (duration * 1000).toInt());
  }
}
