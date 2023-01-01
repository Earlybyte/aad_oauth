import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'model/config.dart';
import 'request/authorization_request.dart';

class RequestCode {
  final Config _config;
  final AuthorizationRequest _authorizationRequest;

  String? _code;

  RequestCode(Config config)
      : _config = config,
        _authorizationRequest = AuthorizationRequest(config);
  Future<String?> requestCode() async {
    _code = null;
    final urlParams = _constructUrlParams();
    var controller = WebViewController();
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setBackgroundColor(const Color(0x00000000));
    await controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          if (request.url
              .startsWith('${_authorizationRequest.url}?$urlParams')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
    await controller
        .loadRequest(Uri.parse('${_authorizationRequest.url}?$urlParams'));

    var webView = WebViewWidget(controller: controller);

    // var webView = WebView(
    //   initialUrl: '${_authorizationRequest.url}?$urlParams',
    //   javascriptMode: JavascriptMode.unrestricted,
    //   navigationDelegate: _navigationDelegate,
    //   backgroundColor: Colors.transparent,
    //   userAgent: _config.userAgent,
    // );

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
    return _code;
  }

  // FutureOr<NavigationDecision> _navigationDelegate(NavigationRequest request) {
  //   var uri = Uri.parse(request.url);

  //   if (uri.queryParameters['error'] != null) {
  //     _config.navigatorKey.currentState!.pop();
  //   }

  //   if (uri.queryParameters['code'] != null) {
  //     _code = uri.queryParameters['code'];
  //     _config.navigatorKey.currentState!.pop();
  //   }
  //   return NavigationDecision.navigate;
  // }

  Future<void> clearCookies() async {
    await WebViewCookieManager().clearCookies();
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
