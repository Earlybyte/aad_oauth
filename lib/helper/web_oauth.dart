/// Microsoft identity platform authentication library.
/// @nodoc
@JS('aadOauth')
library msauth;

import 'dart:async';
import 'package:aad_oauth/helper/core_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/model/msalconfig.dart';
import 'package:js/js.dart';

@JS('init')
external void jsInit(MsalConfig config);

@JS('login')
external void jsLogin(
  bool refreshIfAvailable,
  void Function() onSuccess,
  void Function(dynamic) onError,
);

@JS('logout')
external void jsLogout(
  void Function() onSuccess,
  void Function(dynamic) onError,
);

@JS('getAccessToken')
external String? jsGetAccessToken();

@JS('getIdToken')
external String? jsGetIdToken();

class WebOAuth extends CoreOAuth {
  WebOAuth(Config config) {
    jsInit(MsalConfig.construct(
        tenant: config.tenant,
        policy: config.policy,
        clientId: config.clientId,
        responseType: config.responseType,
        redirectUri: config.redirectUri,
        scope: config.scope,
        responseMode: config.responseMode,
        state: config.state,
        prompt: config.prompt,
        codeChallenge: config.codeChallenge,
        codeChallengeMethod: config.codeChallengeMethod,
        nonce: config.nonce,
        tokenIdentifier: config.tokenIdentifier,
        clientSecret: config.clientSecret,
        resource: config.resource,
        isB2C: config.isB2C,
        loginHint: config.loginHint,
        domainHint: config.domainHint,
        codeVerifier: config.codeVerifier,
        authorizationUrl: config.authorizationUrl,
        tokenUrl: config.tokenUrl));
  }

  @override
  Future<String?> getAccessToken() async {
    return jsGetAccessToken();
  }

  @override
  Future<String?> getIdToken() async {
    return jsGetIdToken();
  }

  @override
  Future<void> login({bool refreshIfAvailable = false}) async {
    final completer = Completer<void>();

    jsLogin(
      refreshIfAvailable,
      allowInterop(completer.complete),
      allowInterop(
        (_error) => completer.completeError(
          Exception('Access denied or authentication canceled.'),
        ),
      ),
    );

    return completer.future;
  }

  @override
  Future<void> logout() async {
    final completer = Completer<void>();

    jsLogout(
      allowInterop(completer.complete),
      allowInterop((error) => completer.completeError(error)),
    );

    return completer.future;
  }
}

CoreOAuth getOAuthConfig(Config config) => WebOAuth(config);
