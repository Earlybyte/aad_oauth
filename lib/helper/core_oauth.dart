import 'package:aad_oauth/helper/choose_oauth.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'package:aad_oauth/helper/mobile_oauth.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'package:aad_oauth/helper/web_oauth.dart';

import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/model/failure.dart';
import 'package:aad_oauth/model/token.dart';
import 'package:dartz/dartz.dart';

class CoreOAuth {
  CoreOAuth();

  Future<Either<Failure, Token>> login(
          {bool refreshIfAvailable = false}) async =>
      throw UnsupportedFailure(ErrorType.Unsupported, 'Unsupported login');

  Future<void> logout() async =>
      throw UnsupportedFailure(ErrorType.Unsupported, 'Unsupported logout');

  Future<String?> getAccessToken() async => throw UnsupportedFailure(
      ErrorType.Unsupported, 'Unsupported getAccessToken');

  Future<String?> getIdToken() async => throw UnsupportedFailure(
      ErrorType.Unsupported, 'Unsupported getAccessToken');

  factory CoreOAuth.fromConfig(Config config) =>
      config.isStub ? CoreOAuth() : getOAuthConfig(config);
}
