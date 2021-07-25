@JS()
library msauth;

import 'dart:async';
import 'dart:ui';
import 'package:aad_oauth/helper/core_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:flutter/src/widgets/media_query.dart';
import 'package:js/js.dart';

@JS('initialiseMSAL')
external void initialiseMSAL(Config config);

@JS('signout')
external void signout();

@JS('GetBearerToken')
external void _GetBearerToken(void Function(MsalTokenResponse) callback,
    void Function(MsalTokenError) errorCallback);

@JS()
@anonymous
class MsalTokenResponse {
  external factory MsalTokenResponse({accessToken, expiresOn});
  external String get accessToken;
  external int get expiresOn;
}

@JS()
@anonymous
class MsalTokenError {
  external factory MsalTokenError(
      {errorCode, errorMessage, name, subError, message, stack});
  external String get errorCode;
  external String get errorMessage;
  external String get name;
  external String get subError;
  external String get message;
  external String get stack;
}

Future<MsalTokenResponse> GetBearerToken() {
  final completer = Completer<MsalTokenResponse>();
  _GetBearerToken(
      allowInterop(completer.complete), allowInterop(completer.completeError));
  return completer.future;
}

class WebOAuth extends CoreOAuth {
  WebOAuth(Config config) {
    initialiseMSAL(config);
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      final accessToken = await GetBearerToken();

      return accessToken.accessToken;
    } catch (e) {
      final msalError = e as MsalTokenError;
      print('$msalError');
      throw Exception('Access denied or authentication canceled.');
    }
  }

  @override
  Future<void> login({bool refreshIfAvailable = false}) async {
    await getAccessToken();
  }

  @override
  Future<void> logout() async {
    signout();
    return;
  }

  @override
  Future<String?> getIdToken() {
    throw UnimplementedError();
  }

  @override
  void setWebViewScreenSize(Rect screenSize) {
    return;
  }

  @override
  void setWebViewScreenSizeFromMedia(MediaQueryData media) {
    return;
  }
}

CoreOAuth getOAuthConfig(Config config) => WebOAuth(config);
