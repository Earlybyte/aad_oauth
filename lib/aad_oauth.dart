library aad_oauth;

import 'model/config.dart';
import 'package:flutter/material.dart';
import 'helper/auth_storage.dart';
import 'model/token.dart';
import 'request_code.dart';
import 'request_token.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

/// Authenticates a user with Azure Active Directory using OAuth2.0.
class AadOAuth {
  static Config _config;
  AuthStorage _authStorage;
  Token _token;
  RequestCode _requestCode;
  RequestToken _requestToken;
  bool _initialized;

  /// Instantiating AadOAuth authentication.
  /// [config] Parameters according to official Microsoft Documentation.
  AadOAuth(Config config) {
    _config = config;
    _authStorage = AuthStorage(tokenIdentifier: config.tokenIdentifier);
    _requestCode = RequestCode(_config);
    _requestToken = RequestToken(_config);
    _initialized = false;
  }

  Future<void> init() async {
    if (!_initialized) {
      // load token from cache
      _token = await _authStorage.loadTokenToCache();
      _initialized = true;
    }
  }

  /// Set [screenSize] of webview.
  void setWebViewScreenSize(Rect screenSize) {
    if (screenSize != _config.screenSize) {
      _config.screenSize = screenSize;
      _requestCode.sizeChanged();
    }
  }

  /// Perform Azure AD login.
  Future<void> login() async {
    await _removeOldTokenOnFirstLogin();
    if (!Token.tokenIsValid(_token)) {
      await _performAuthorization();
    }
  }

  /// Retrieve OAuth access token.
  Future<String> getAccessToken() async {
    if (!Token.tokenIsValid(_token)) await _performAuthorization();

    return _token.accessToken;
  }

  /// Retrieve OAuth id token. (JSON Web Token)
  Future<String> getIdToken() async {
    if (!Token.tokenIsValid(_token)) await _performAuthorization();

    return _token.idToken;
  }

  /// Get status of user login by checking token.
  bool tokenIsValid() {
    return Token.tokenIsValid(_token);
  }

  /// Perform Azure AD logout.
  Future<void> logout() async {
    await _authStorage.clear();
    await _requestCode.clearCookies();
    _token = null;
    AadOAuth(_config);
  }

  Future<void> _performAuthorization() async {
    await init();
    //still have refreh token / try to get access token with refresh token
    if (_token != null) {
      await _performRefreshAuthFlow();
    } else {
      try {
        await _performFullAuthFlow();
      } catch (e) {
        rethrow;
      }
    }

    //save token to cache
    await _authStorage.saveTokenToCache(_token);
  }

  Future<void> _performFullAuthFlow() async {
    String code;
    try {
      code = await _requestCode.requestCode();
      if (code == null) {
        throw Exception('Access denied or authentation canceled.');
      }
      _token = await _requestToken.requestToken(code);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _performRefreshAuthFlow() async {
    if (_token.refreshToken != null) {
      try {
        _token = await _requestToken.requestRefreshToken(_token.refreshToken);
      } catch (e) {
        //do nothing (because later we try to do a full oauth code flow request)
      }
    }
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
