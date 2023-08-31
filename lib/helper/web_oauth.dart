/// Microsoft identity platform authentication library.
/// @nodoc
@JS('aadOauth')
library msauth;

import 'dart:async';
import 'dart:convert';

import 'package:aad_oauth/helper/core_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/model/failure.dart';
import 'package:aad_oauth/model/msalconfig.dart';
import 'package:aad_oauth/model/token.dart';
import 'package:dartz/dartz.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS('init')
external void jsInit(MsalConfig config);

@JS('login')
external void jsLogin(
  bool refreshIfAvailable,
  bool useRedirect,
  void Function(dynamic) onSuccess,
  void Function(dynamic) onError,
);

@JS('logout')
external void jsLogout(
  void Function() onSuccess,
  void Function(dynamic) onError,
);

@JS('getAccessToken')
external Object jsGetAccessToken();

@JS('getIdToken')
external Object jsGetIdToken();

@JS('hasCachedAccountInformation')
external bool jsHasCachedAccountInformation();

@JS('refreshToken')
external void jsRefreshToken(
  void Function(dynamic) onSuccess,
  void Function(dynamic) onError,
);

class WebOAuth extends CoreOAuth {
  final Config config;
  WebOAuth(this.config) {
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
        tokenUrl: config.tokenUrl,
        cacheLocation: config.cacheLocation.value,
        customParameters: jsonEncode(config.customParameters),
        postLogoutRedirectUri: config.postLogoutRedirectUri));
  }

  @override
  Future<String?> getAccessToken() async {
    return promiseToFuture(jsGetAccessToken());
  }

  @override
  Future<String?> getIdToken() async {
    return promiseToFuture(jsGetIdToken());
  }

  @override
  Future<bool> get hasCachedAccountInformation =>
      Future<bool>.value(jsHasCachedAccountInformation());

  @override
  Future<Either<Failure, Token>> login(
      {bool refreshIfAvailable = false}) async {
    final completer = Completer<Either<Failure, Token>>();

    jsLogin(
      refreshIfAvailable,
      config.webUseRedirect,
      allowInterop(
          (_value) => completer.complete(Right(Token(accessToken: _value)))),
      allowInterop((_error) => completer.complete(Left(AadOauthFailure(
            ErrorType.AccessDeniedOrAuthenticationCanceled,
            'Access denied or authentication canceled. Error: ${_error.toString()}',
          )))),
    );

    return completer.future;
  }

  @override
  Future<Either<Failure, Token>> refreshToken() {
    final completer = Completer<Either<Failure, Token>>();

    jsRefreshToken(
      allowInterop(
          (_value) => completer.complete(Right(Token(accessToken: _value)))),
      allowInterop((_error) => completer.complete(Left(AadOauthFailure(
            ErrorType.AccessDeniedOrAuthenticationCanceled,
            'Access denied or authentication canceled. Error: ${_error.toString()}',
          )))),
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
