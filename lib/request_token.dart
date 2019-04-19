import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'model/config.dart';
import 'request/token_refresh_request.dart';
import 'request/token_request.dart';
import 'model/token.dart';

class RequestToken {
  final Config config;
  TokenRequestDetails _tokenRequest;
  TokenRefreshRequestDetails _tokenRefreshRequest;

  RequestToken(this.config);

  Future<Token> requestToken(String code) async {
    _generateTokenRequest(code);
    return await _sendTokenRequest(_tokenRequest.url, _tokenRequest.params, _tokenRequest.headers);
  }

  Future<Token> requestRefreshToken(String refreshToken) async  {
    _generateTokenRefreshRequest(refreshToken);
    return await _sendTokenRequest(_tokenRefreshRequest.url, _tokenRefreshRequest.params, _tokenRefreshRequest.headers);
  }

  Future<Token> _sendTokenRequest(String url, Map<String, String> params, Map<String, String> headers) async {
    Response response = await post(url,
        body: params,
        headers: headers);
    Map<String, dynamic> tokenJson = json.decode(response.body);
    Token token = new Token.fromJson(tokenJson);
    return token;
  }

  void _generateTokenRequest(String code) {
    _tokenRequest = new TokenRequestDetails(config, code);
  }

  void _generateTokenRefreshRequest(String refreshToken) {
    _tokenRefreshRequest = new TokenRefreshRequestDetails(config, refreshToken);
  }  
}