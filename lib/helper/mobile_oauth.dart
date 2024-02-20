import 'dart:async';

import 'package:aad_oauth/helper/core_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/model/failure.dart';
import 'package:aad_oauth/model/token.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../request_code.dart';
import '../request_token.dart';
import 'auth_storage.dart';

class MobileOAuth extends CoreOAuth {
  final AuthStorage _authStorage;
  final RequestCode _requestCode;
  final RequestToken _requestToken;

  Completer<String?>? _accessTokenCompleter;

  /// Instantiating MobileAadOAuth authentication.
  /// [config] Parameters according to official Microsoft Documentation.
  MobileOAuth(Config config)
      : _authStorage = AuthStorage(
          FlutterSecureStorage(),
          aOptions: config.aOptions,
          tokenIdentifier: config.tokenIdentifier,
        ),
        _requestCode = RequestCode(config),
        _requestToken = RequestToken(config);

  /// Perform Azure AD login.
  ///
  /// Setting [refreshIfAvailable] to `true` will attempt to re-authenticate
  /// with the existing refresh token, if any, even though the access token may
  /// still be valid. If there's no refresh token the existing access token
  /// will be returned, as long as we deem it still valid. In the event that
  /// both access and refresh tokens are invalid, the web gui will be used.
  @override
  Future<Either<Failure, Token>> login(
      {bool refreshIfAvailable = false}) async {
    await _removeOldTokenOnFirstLogin();
    return await _authorization(refreshIfAvailable: refreshIfAvailable);
  }

  /// Tries to silently login. will try to use the existing refresh token to get
  /// a new token.
  @override
  Future<Either<Failure, Token>> refreshToken() async {
    var token = await _authStorage.loadTokenFromCache();

    if (!token.hasValidAccessToken()) {
      token.accessToken = null;
    }

    if (token.hasRefreshToken()) {
      final result =
          await _requestToken.requestRefreshToken(token.refreshToken!);
      //If refresh token request throws an exception, we have to do
      //a fullAuthFlow.
      result.fold(
        (l) => token.accessToken = null,
        (r) => token = r,
      );
    }

    await _authStorage.saveTokenToCache(token);
    return Right(token);
  }

  /// Retrieve cached OAuth Access Token.
  /// If access token is not valid it tries to refresh the token.
  /// parallel can be made [getAccessToken] will make sure only one request
  /// for refreshing token is made.
  @override
  Future<String?> getAccessToken() async {
    if (_accessTokenCompleter != null) {
      return _accessTokenCompleter?.future;
    } else {
      _accessTokenCompleter = Completer();
    }

    var token = await _authStorage.loadTokenFromCache();
    String? accessToken;

    if (token.hasValidAccessToken()) {
      accessToken = token.accessToken;
    } else {
      await refreshToken();
      token = await _authStorage.loadTokenFromCache();
      accessToken = token.accessToken;
    }

    _accessTokenCompleter?.complete(accessToken);
    _accessTokenCompleter = null;
    return accessToken;
  }

  /// Retrieve cached OAuth Id Token.
  @override
  Future<String?> getIdToken() async =>
      (await _authStorage.loadTokenFromCache()).idToken;

  /// Perform Azure AD logout.
  @override
  Future<void> logout({bool showPopup = true}) async {
    await _authStorage.clear();
    await _requestCode.clearCookies();
  }

  @override
  Future<bool> get hasCachedAccountInformation async =>
      (await _authStorage.loadTokenFromCache()).accessToken != null;

  /// Authorize user via refresh token or web gui if necessary.
  ///
  /// Setting [refreshIfAvailable] to [true] will attempt to re-authenticate
  /// with the existing refresh token, if any, even though the access token may
  /// still be valid. If there's no refresh token the existing access token
  /// will be returned, as long as we deem it still valid. In the event that
  /// both access and refresh tokens are invalid, the web gui will be used.
  Future<Either<Failure, Token>> _authorization(
      {bool refreshIfAvailable = false}) async {
    var token = await _authStorage.loadTokenFromCache();

    if (!refreshIfAvailable) {
      if (token.hasValidAccessToken()) {
        return Right(token);
      }
    }

    if (token.hasRefreshToken()) {
      final result =
          await _requestToken.requestRefreshToken(token.refreshToken!);
      //If refresh token request throws an exception, we have to do
      //a fullAuthFlow.
      result.fold(
        (l) => token.accessToken = null,
        (r) => token = r,
      );
    }

    if (!token.hasValidAccessToken()) {
      final result = await _performFullAuthFlow();
      Failure? failure;
      result.fold(
        (l) => failure = l,
        (r) => token = r,
      );
      if (failure != null) {
        return Left(failure!);
      }
    }

    await _authStorage.saveTokenToCache(token);
    return Right(token);
  }

  /// Authorize user via refresh token or web gui if necessary.
  Future<Either<Failure, Token>> _performFullAuthFlow() async {
    var code = await _requestCode.requestCode();
    if (code == null) {
      return Left(AadOauthFailure(
        errorType: ErrorType.accessDeniedOrAuthenticationCanceled,
        message: 'Access denied or authentication canceled.',
      ));
    }
    return await _requestToken.requestToken(code);
  }

  Future<void> _removeOldTokenOnFirstLogin() async {
    var prefs = await SharedPreferences.getInstance();
    final keyFreshInstall = 'freshInstall';
    if (!prefs.getKeys().contains(keyFreshInstall)) {
      await logout();
      await prefs.setBool(keyFreshInstall, false);
    }
  }
}

CoreOAuth getOAuthConfig(Config config) => MobileOAuth(config);
