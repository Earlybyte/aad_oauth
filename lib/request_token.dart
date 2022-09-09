import 'dart:async';
import 'dart:convert';
import 'package:aad_oauth/model/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart';
import 'model/config.dart';
import 'request/token_refresh_request.dart';
import 'request/token_request.dart';
import 'model/token.dart';

class RequestToken {
  final Config config;

  RequestToken(this.config);

  Future<Either<Failure, Token>> requestToken(String code) async {
    final _tokenRequest = TokenRequestDetails(config, code);
    return await _sendTokenRequest(
        _tokenRequest.url, _tokenRequest.params, _tokenRequest.headers);
  }

  Future<Either<Failure, Token>> requestRefreshToken(
      String refreshToken) async {
    final _tokenRefreshRequest =
        TokenRefreshRequestDetails(config, refreshToken);
    return await _sendTokenRequest(_tokenRefreshRequest.url,
        _tokenRefreshRequest.params, _tokenRefreshRequest.headers);
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
      return Left(
          RequestFailure(ErrorType.InvalidJson, 'Token json is invalid'));
    } catch (e) {
      return Left(RequestFailure(
          ErrorType.InvalidJson, 'Token json is invalid: ${e.toString()}'));
    }
  }
}
