import 'dart:async';
import 'dart:convert';
import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/model/token.dart';
import 'package:aad_oauth/request/token_refresh_request.dart';
import 'package:aad_oauth/request/token_request.dart';
import 'package:http/http.dart';

class RequestToken {
  final AadConfig config;

  RequestToken(this.config);

  Future<Token> requestToken(String code) async {
    final _tokenRequest = TokenRequestDetails(config, code);

    return await _sendTokenRequest(
        _tokenRequest.url, _tokenRequest.params, _tokenRequest.headers);
  }

  Future<Token> requestRefreshToken(String refreshToken) async {
    final _tokenRefreshRequest =
        TokenRefreshRequestDetails(config, refreshToken);
    return await _sendTokenRequest(_tokenRefreshRequest.url,
        _tokenRefreshRequest.params, _tokenRefreshRequest.headers);
  }

  Future<Token> _sendTokenRequest(String url, Map<String, String> params,
      Map<String, String> headers) async {
    var response = await post(Uri.parse(url), body: params, headers: headers);
    Map<String, dynamic> tokenJson = json.decode(response.body);
    var token = Token.fromJson(tokenJson);
    return token;
  }
}
