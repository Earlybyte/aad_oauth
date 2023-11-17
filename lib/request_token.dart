import 'dart:async';
import 'dart:convert';

import 'package:aad_oauth/model/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart';

import 'model/config.dart';
import 'model/token.dart';
import 'request/token_refresh_request.dart';
import 'request/token_request.dart';

class RequestToken {
  final Config config;

  RequestToken(this.config);

  Future<Either<Failure, Token>> requestToken(String code) async {
    final tokenRequest = TokenRequestDetails(config, code);
    return await _sendTokenRequest(
        tokenRequest.url, tokenRequest.params, tokenRequest.headers);
  }

  Future<Either<Failure, Token>> requestRefreshToken(
      String refreshToken) async {
    final tokenRefreshRequest =
        TokenRefreshRequestDetails(config, refreshToken);
    return await _sendTokenRequest(tokenRefreshRequest.url,
        tokenRefreshRequest.params, tokenRefreshRequest.headers);
  }

  Future<Either<Failure, Token>> _sendTokenRequest(String url,
      Map<String, String> params, Map<String, String> headers) async {
    try {
      var response = await post(Uri.parse(url), body: params, headers: headers);
      final tokenJson = json.decode(response.body);
      if (tokenJson is Map<String, dynamic>) {
        var token = Token.fromJson(tokenJson);
        return Right(token);
      }
      return Left(RequestFailure(
          errorType: ErrorType.invalidJson, message: 'Token json is invalid'));
    } catch (e) {
      return Left(RequestFailure(
          errorType: ErrorType.invalidJson,
          message: 'Token json is invalid: ${e.toString()}'));
    }
  }
}
