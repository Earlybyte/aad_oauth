/// Microsoft identity platform authentication library.
/// @nodoc
@JS('aadOauth')
library msauth;

import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:js/js.dart';

import '../model/config.dart';
import '../model/failure.dart';
import '../model/msalconfig.dart';
import '../model/token.dart';
import 'auth_storage.dart';
import 'core_oauth.dart';

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
external String? jsGetAccessToken();

@JS('getIdToken')
external String? jsGetIdToken();

class WebOAuth extends CoreOAuth {
  final AuthStorage _authStorage;

  final Config config;
  WebOAuth(this.config)
      : _authStorage = AuthStorage(
          tokenIdentifier: config.tokenIdentifier,
          aOptions: config.aOptions,
        ) {
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
    return (await _authStorage.loadTokenFromCache()).accessToken ??
        jsGetAccessToken();
  }

  @override
  Future<String?> getIdToken() async {
    return (await _authStorage.loadTokenFromCache()).idToken ?? jsGetIdToken();
  }

  @override
  Future<Either<Failure, Token>> login(
      {bool refreshIfAvailable = false}) async {
    var token = await _authStorage.loadTokenFromCache();
    final completer = Completer<Either<Failure, Token>>();
    if (!refreshIfAvailable) {
      if (token.hasValidAccessToken()) {
        return Right(token);
      }
    }

    jsLogin(
      refreshIfAvailable,
      config.webUseRedirect,
      allowInterop(
        (_value) => completer.complete(Right(Token(accessToken: _value))),
      ),
      allowInterop(
        (_error) => completer.complete(Left(AadOauthFailure(
          ErrorType.accessDeniedOrAuthenticationCanceled,
          'Access denied or authentication canceled. Error: ${_error.toString()}',
        ))),
      ),
    );

    var failure;
    final result = await completer.future;
    result.fold(
      (l) => failure = l,
      (r) => token = r,
    );
    if (failure != null) {
      return Left(failure);
    }

    await _authStorage.saveTokenToCache(token);

    return completer.future;
  }

  @override
  Future<void> logout() async {
    final completer = Completer<void>();

    jsLogout(
      allowInterop(completer.complete),
      allowInterop((error) => completer.completeError(error)),
    );

    await _authStorage.clear();

    return completer.future;
  }
}

CoreOAuth getOAuthConfig(Config config) => WebOAuth(config);
