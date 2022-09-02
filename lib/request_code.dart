import 'dart:async';

import 'package:aad_oauth/model/aad_auth_exception.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'model/config.dart';
import 'request/authorization_request.dart';

class RequestCode {
  final Config _config;
  final AuthorizationRequest _authorizationRequest;

  String? _code;
  Exception? _exception;

  RequestCode(Config config)
      : _config = config,
        _authorizationRequest = AuthorizationRequest(config);
  Future<String?> requestCode() async {
    _code = null;
    final urlParams = _constructUrlParams();
    var webView = WebView(
      initialUrl: '${_authorizationRequest.url}?$urlParams',
      javascriptMode: JavascriptMode.unrestricted,
      navigationDelegate: _navigationDelegate,
      backgroundColor: Colors.transparent,
    );

    await _config.navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
            body: SafeArea(
          child: Stack(
            children: [_config.loader, webView],
          ),
        )),
      ),
    );

    final exception = _exception;
    if (exception != null) {
      throw exception;
    }

    return _code;
  }

  FutureOr<NavigationDecision> _navigationDelegate(NavigationRequest request) {
    var uri = Uri.parse(request.url);

    final errorCode = uri.queryParameters['error'];
    if (errorCode != null) {
      _exception = AadAuthException(
        error: errorCode,
        errorSubcode: uri.queryParameters['error_subcode'],
      );
      _config.navigatorKey.currentState!.pop();
    }

    if (uri.queryParameters['code'] != null) {
      _code = uri.queryParameters['code'];
      _config.navigatorKey.currentState!.pop();
    }
    return NavigationDecision.navigate;
  }

  Future<void> clearCookies() async {
    await CookieManager().clearCookies();
  }

  String _constructUrlParams() =>
      _mapToQueryParams(_authorizationRequest.parameters);

  String _mapToQueryParams(Map<String, String> params) {
    final queryParams = <String>[];
    params.forEach((String key, String value) =>
        queryParams.add('$key=${Uri.encodeQueryComponent(value)}'));
    return queryParams.join('&');
  }
}
