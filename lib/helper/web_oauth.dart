/// Microsoft identity platform authentication library.
@JS()
library msauth;

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:aad_oauth/fp/either.dart';
import 'package:aad_oauth/helper/core_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/model/failure.dart';
import 'package:aad_oauth/model/msalconfig.dart';
import 'package:aad_oauth/model/token.dart';

@JS('aadOauth.init')
external void jsInit(MsalConfig config);

@JS('aadOauth.login')
external void jsLogin(bool refreshIfAvailable, bool useRedirect, JSFunction onSuccess, JSFunction onError);

@JS('aadOauth.logout')
external void jsLogout(JSFunction onSuccess, JSFunction onError, bool showPopup);

@JS('aadOauth.getAccessToken')
external JSPromise<JSString?> jsGetAccessToken();

@JS('aadOauth.getIdToken')
external JSPromise<JSString?> jsGetIdToken();

@JS('aadOauth.hasCachedAccountInformation')
external JSBoolean jsHasCachedAccountInformation();

@JS('aadOauth.refreshToken')
external void jsRefreshToken(JSFunction onSuccess, JSFunction onError);

class WebOAuth extends CoreOAuth {
  final Config config;

  WebOAuth(this.config) {
    final msalConfig = MsalConfigFactory.construct(
      tenant: config.tenant,
      clientId: config.clientId,
      scope: config.scope,
      responseType: config.responseType,
      redirectUri: config.redirectUri,
      state: config.state,
      codeChallenge: config.codeChallenge,
      codeChallengeMethod: config.codeChallengeMethod,
      nonce: config.nonce,
      tokenIdentifier: config.tokenIdentifier,
      clientSecret: config.clientSecret,
      resource: config.resource,
      isB2C: config.isB2C,
      policy: config.policy,
      customAuthorizationUrl: config.customAuthorizationUrl,
      customTokenUrl: config.customTokenUrl,
      loginHint: config.loginHint,
      domainHint: config.domainHint,
      codeVerifier: config.codeVerifier,
      authorizationUrl: config.authorizationUrl,
      tokenUrl: config.tokenUrl,
      cacheLocation: config.cacheLocation.value,
      customParameters: jsonEncode(config.customParameters),
      postLogoutRedirectUri: config.postLogoutRedirectUri,
    );

    jsInit(msalConfig);
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      final JSString? result = await jsGetAccessToken().toDart;
      return result?.toDart;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getIdToken() async {
    try {
      final JSString? result = await jsGetIdToken().toDart;
      return result?.toDart;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> get hasCachedAccountInformation async {
    try {
      final JSBoolean result = jsHasCachedAccountInformation();
      return result.toDart;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, Token>> login({bool refreshIfAvailable = false}) async {
    final completer = Completer<Either<Failure, Token>>();

    final onSuccess = ((String? token) {
      completer.complete(Right(Token(accessToken: token ?? '')));
    }).toJS;

    final onError = ((JSAny error) {
      completer.complete(Left(AadOauthFailure(
        errorType: ErrorType.accessDeniedOrAuthenticationCanceled,
        message: 'Access denied or authentication canceled. Error: ${error.toString()}',
      )));
    }).toJS;

    jsLogin(refreshIfAvailable, config.webUseRedirect, onSuccess, onError);

    return completer.future;
  }

  @override
  Future<Either<Failure, Token>> refreshToken() async {
    final completer = Completer<Either<Failure, Token>>();

    final onSuccess = ((String? token) {
      completer.complete(Right(Token(accessToken: token ?? '')));
    }).toJS;

    final onError = ((JSAny error) {
      completer.complete(Left(AadOauthFailure(
        errorType: ErrorType.accessDeniedOrAuthenticationCanceled,
        message: 'Access denied or authentication canceled. Error: ${error.toString()}',
      )));
    }).toJS;

    jsRefreshToken(onSuccess, onError);

    return completer.future;
  }

  @override
  Future<void> logout({bool showPopup = true, bool clearCookies = true}) async {
    final completer = Completer<void>();

    final onSuccess = (() => completer.complete()).toJS;
    final onError = ((JSAny error) => completer.completeError(error)).toJS;

    jsLogout(onSuccess, onError, showPopup);

    return completer.future;
  }
}

CoreOAuth getOAuthConfig(Config config) => WebOAuth(config);
