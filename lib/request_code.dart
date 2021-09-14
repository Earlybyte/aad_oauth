import 'dart:async';
import 'request/authorization_request.dart';
import 'model/config.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class RequestCode {
  final StreamController<String?> _onCodeListener = StreamController();
  final FlutterWebviewPlugin _webView = FlutterWebviewPlugin();
  final Config _config;
  final AuthorizationRequest _authorizationRequest;

  late Stream<String?> _onCodeStream;

  RequestCode(Config config)
      : _config = config,
        _authorizationRequest = AuthorizationRequest(config) {
    _onCodeStream = _onCodeListener.stream.asBroadcastStream();
  }
  Future<String?> requestCode() async {
    String? code;
    final urlParams = _constructUrlParams();

    await _webView.launch(
      '${_authorizationRequest.url}?$urlParams',
      clearCookies: _authorizationRequest.clearCookies,
      hidden: false,
      rect: _config.screenSize,
      userAgent: _config.userAgent,
    );

    _webView.onUrlChanged.listen((String url) {
      var uri = Uri.parse(url);

      if (uri.queryParameters['error'] != null) {
        _webView.close();
        _onCodeListener.add(null);
      }

      if (uri.queryParameters['code'] != null) {
        _webView.close();
        _onCodeListener.add(uri.queryParameters['code']);
      }
    });

    code = await _onCode.first;
    return code;
  }

  void sizeChanged() {
    _webView.resize(_config.screenSize!);
  }

  Future<void> clearCookies() async {
    await _webView.launch('', hidden: true);
    await _webView.cleanCookies();
    await _webView.clearCache();
    await _webView.close();
  }

  Stream<String?> get _onCode => _onCodeStream;

  String _constructUrlParams() =>
      _mapToQueryParams(_authorizationRequest.parameters);

  String _mapToQueryParams(Map<String, String> params) {
    final queryParams = <String>[];
    params.forEach((String key, String value) =>
        queryParams.add('$key=${Uri.encodeQueryComponent(value)}'));
    return queryParams.join('&');
  }
}
