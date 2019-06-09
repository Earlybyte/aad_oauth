import 'dart:async';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'request/authorization_request.dart';
import 'model/config.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class RequestCode {
  final StreamController<String> _onCodeListener = new StreamController();
  final FlutterWebviewPlugin _webView = new FlutterWebviewPlugin();
  final Config _config;
  AuthorizationRequest _authorizationRequest;

  var _onCodeStream;

  RequestCode(Config config) : _config = config {
    _authorizationRequest = new AuthorizationRequest(config);
  }

  Future<String> requestCode() async {
    var code;
    final String urlParams = _constructUrlParams();

    // workaround for webview overlapping statusbar
    // if we have a screen size use it to adjust the webview
    await _webView.launch(
        Uri.encodeFull("${_authorizationRequest.url}?$urlParams"),
        clearCookies: _authorizationRequest.clearCookies,
        hidden: true,
        rect: _config.screenSize);

    _webView.onStateChanged.listen((WebViewStateChanged change) {
      if (change.type.index == 2) _webView.show();
    });

    _webView.onUrlChanged.listen((String url) {
      Uri uri = Uri.parse(url);
      Uri configUri = Uri.parse(_authorizationRequest.redirectUrl);
      if (uri.queryParameters.containsKey("error")) {
        // An error occurred (e.g. user didn't authenticate, or pressed Back
        // or some othe problem) - leave it to the caller to work out what to
        // do. Publish a null token
        _onCodeListener.add(null);
        return;
      }
      if (uri.host == configUri.host)
        _onCodeListener.add(uri.queryParameters["code"]);
    });

    code = await _onCode.first;
    await _webView.close();

    return code;
  }

  void sizeChanged() {
    _webView.resize(_config.screenSize);
  }

  Future<void> clearCookies() async {
    await _webView.launch("", hidden: true, clearCookies: true);
    await _webView.close();
  }

  Stream<String> get _onCode =>
      _onCodeStream ??= _onCodeListener.stream.asBroadcastStream();

  String _constructUrlParams() =>
      _mapToQueryParams(_authorizationRequest.parameters);

  String _mapToQueryParams(Map<String, String> params) {
    final queryParams = <String>[];
    params
        .forEach((String key, String value) => queryParams.add("$key=$value"));
    return queryParams.join("&");
  }
}
