library aad_oauth;

import 'model/config.dart';
import 'package:flutter/material.dart';
import 'helper/auth_storage.dart';
import 'model/token.dart';
import 'request_code.dart';
import 'request_token.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class AadOAuth {
  static Config _config;
  AuthStorage _authStorage;
  Token _token;
  RequestCode _requestCode;
  RequestToken _requestToken;

  factory AadOAuth(config) {
    if ( AadOAuth._instance == null )
      AadOAuth._instance = new AadOAuth._internal(config);
    return _instance;
  }

  static AadOAuth _instance;

  AadOAuth._internal(config){
    AadOAuth._config = config;
    _authStorage = _authStorage ?? new AuthStorage();
    _requestCode = new RequestCode(_config);
    _requestToken = new RequestToken(_config);
  }

  void setWebViewScreenSize(Rect screenSize) {
    if (screenSize != _config.screenSize) {
      _config.screenSize = screenSize;
      _requestCode.sizeChanged();
    }
  }
  
  Future<void> login() async {
    await _removeOldTokenOnFirstLogin();
    if (!Token.tokenIsValid(_token) )
      await _performAuthorization();
  }

  Future<String> getAccessToken() async {
    if (!Token.tokenIsValid(_token) )
      await _performAuthorization();
    if (_token == null) return null;
    return _token.accessToken;
  }

  bool tokenIsValid() {
    return Token.tokenIsValid(_token);
  }

  Future<void> logout() async {
    await _authStorage.clear();
    await _requestCode.clearCookies();
    _token = null;
    AadOAuth(_config);
  }

  Future<void> _performAuthorization() async {
    // load token from cache
    _token = await _authStorage.loadTokenToCache();

    //still have refreh token / try to get new access token with refresh token
    if (_token != null)
      await _performRefreshAuthFlow();

    // if we have no refresh token try to perform full request code oauth flow
    else {
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final _keyFreshInstall = "freshInstall";
    if (!prefs.getKeys().contains(_keyFreshInstall)) {
      logout();
      await prefs.setBool(_keyFreshInstall, false);
    }
  }
}
