class VideoUtil {
  /// If videoId is passed as url then no conversion is done.
  static String? convertUrlToId(String url, {bool trimWhitespaces = true}) {
    if (!url.contains("http") && (url.length == 11)) return url;
    if (trimWhitespaces) url = url.trim();

    const contentUrlPattern = r'^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?';
    const embedUrlPattern =
        r'^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/';
    const altUrlPattern = r'^https:\/\/youtu\.be\/';
    const shortsUrlPattern = r'^https:\/\/(?:www\.|m\.)?youtube\.com\/shorts\/';
    const idPattern = r'([_\-a-zA-Z0-9]{11}).*$';

    for (var regex in [
      '${contentUrlPattern}v=$idPattern',
      '$embedUrlPattern$idPattern',
      '$altUrlPattern$idPattern',
      '$shortsUrlPattern$idPattern',
    ]) {
      Match? match = RegExp(regex).firstMatch(url);
      if (match != null && match.groupCount >= 1) return match.group(1);
    }

    return null;
  }
}

class YoutubePlayerVars {
  final bool autoPlay;
  final bool showControls;
  final int playInline = 1;
  final bool modestBranding;
  final bool fullScreen;
  final int disableKb;

  YoutubePlayerVars({
    this.autoPlay = false,
    this.showControls = true,
    this.modestBranding = true,
    this.fullScreen = true,
    this.disableKb = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'autoplay': boolToInt(autoPlay),
      'controls': boolToInt(showControls),
      'playsinline': playInline,
      'iv_load_policy': 3,
      'modestbranding': boolToInt(modestBranding),
      'fs': boolToInt(fullScreen),
      'disablekb': disableKb,
    };
  }

  int boolToInt(bool val) => val ? 1 : 0;
}
