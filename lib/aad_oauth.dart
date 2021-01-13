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
    _token = Token();
    _authStorage = AuthStorage(tokenIdentifier: config.tokenIdentifier);
    _requestCode = RequestCode(_config);
    _requestToken = RequestToken(_config);
    _initialized = false;
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
    if (!_token.hasValidAccessToken()) {
      await _performAuthorization();
    }
  }

  /// Retrieve OAuth access token.
  Future<String> getAccessToken() async {
    if (!_token.hasValidAccessToken()) await _performAuthorization();

    return _token.accessToken;
  }

  /// Retrieve OAuth id token. (JSON Web Token)
  Future<String> getIdToken() async {
    if (!_token.hasValidAccessToken()) await _performAuthorization();

    return _token.idToken;
  }

  /// Perform Azure AD logout.
  Future<void> logout() async {
    await _authStorage.clear();
    await _requestCode.clearCookies();
    _token = Token();
    AadOAuth(_config);
  }

  Future<void> _performAuthorization() async {
    _token = await _authStorage.loadTokenFromCache();

    //still have refresh token / try to get access token with refresh token
    if (_token.hasRefreshToken()) {
      await _performRefreshAuthFlow();
      if (!_token.hasValidAccessToken()) {
        await _performFullAuthFlow();
      }
    } else {
      await _performFullAuthFlow();
    }

    //save token to cache
    await _authStorage.saveTokenToCache(_token);
  }

  Future<void> _performFullAuthFlow() async {
    var code = await _requestCode.requestCode();
    if (code == null) {
      throw Exception('Access denied or authentication canceled.');
    }
    _token = await _requestToken.requestToken(code);
  }

  Future<void> _performRefreshAuthFlow() async {
    _token = await _requestToken.requestRefreshToken(_token.refreshToken);
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
