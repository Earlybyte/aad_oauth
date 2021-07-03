import 'dart:async';
import 'dart:convert';
import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/model/token.dart';
import 'package:aad_oauth/request/request_details.dart';
import 'package:aad_oauth/request/token_refresh_request.dart';
import 'package:aad_oauth/request/token_request.dart';
import 'package:http/http.dart';

class RequestToken {
  final AadConfig config;

  RequestToken(this.config);

  Future<Token> requestToken(String code) async {
    return await _sendTokenRequest(TokenRequestDetails(config, code));
  }

  Future<Token> requestRefreshToken(String refreshToken) async {
    return await _sendTokenRequest(
        TokenRefreshRequestDetails(config, refreshToken));
  }

  Future<Token> _sendTokenRequest(RequestDetails request) async {
    var response = await post(request.uri,
        body: request.parameters, headers: request.headers);
    Map<String, dynamic> tokenJson = json.decode(response.body);
    var token = Token.fromJson(tokenJson);
    return token;
  }
}
