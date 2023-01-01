import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/config.dart';
import '../model/failure.dart';
import '../model/token.dart';
import '../request_code.dart';
import '../request_token.dart';
import 'auth_storage.dart';
import 'core_oauth.dart';

class MobileOAuth extends CoreOAuth {
  final AuthStorage _authStorage;
  final RequestCode _requestCode;
  final RequestToken _requestToken;

  /// Instantiating MobileAadOAuth authentication.
  /// [config] Parameters according to official Microsoft Documentation.
  MobileOAuth(Config config)
      : _authStorage = AuthStorage(
          tokenIdentifier: config.tokenIdentifier,
          aOptions: config.aOptions,
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

  /// Retrieve cached OAuth Access Token.
  @override
  Future<String?> getAccessToken() async =>
      (await _authStorage.loadTokenFromCache()).accessToken;

  /// Retrieve cached OAuth Id Token.
  @override
  Future<String?> getIdToken() async =>
      (await _authStorage.loadTokenFromCache()).idToken;

  /// Perform Azure AD logout.
  @override
  Future<void> logout() async {
    await _authStorage.clear();
    await _requestCode.clearCookies();
  }

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
      var failure;
      result.fold(
        (l) => failure = l,
        (r) => token = r,
      );
      if (failure != null) {
        return Left(failure);
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
        ErrorType.accessDeniedOrAuthenticationCanceled,
        'Access denied or authentication canceled.',
      ));
    }
    return await _requestToken.requestToken(code);
  }

  Future<void> _removeOldTokenOnFirstLogin() async {
    var prefs = await SharedPreferences.getInstance();
    final _keyFreshInstall = 'freshInstall';
    if (!prefs.getKeys().contains(_keyFreshInstall)) {
      await logout();
      await prefs.setBool(_keyFreshInstall, false);
    }
  }
}

CoreOAuth getOAuthConfig(Config config) => MobileOAuth(config);
