import 'package:aad_oauth/helper/choose_oauth.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'package:aad_oauth/helper/mobile_oauth.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'package:aad_oauth/helper/web_oauth.dart';

import 'package:aad_oauth/model/config.dart';
import 'package:flutter/widgets.dart';

abstract class CoreOAuth {
  CoreOAuth();

  void setWebViewScreenSize(Rect screenSize);

  void setWebViewScreenSizeFromMedia(MediaQueryData media);

  Future<void> login({bool refreshIfAvailable = false});

  Future<void> logout();

  Future<String?> getAccessToken();

  Future<String?> getIdToken();

  factory CoreOAuth.fromConfig(Config config) => getOAuthConfig(config);
}
